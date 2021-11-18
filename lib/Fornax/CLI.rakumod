use Fornax::GenerateFrame;

subset File of Str where *.IO.f;

#| Parses fornax format file to extract metadata.
grammar Metadata {
    rule TOP {  <rows> <cols> }
    token rows { 'rows:' <(\d+)> }
    token cols { 'cols:' <(\d+)> }
}

proto MAIN(|) is export { unless so @*ARGS { put $*USAGE; exit }; {*} }

#| Collection of tools to visualize Path Finding Algorithms
multi sub MAIN(
    File $input, #= fornax format file (solved)

    Int() :$batch = 4, #= number of iterations to process at once (default: 4)
    Int() :fps($frame-rate) = 1, #= frame rate for video solution (default: 1)
    Bool :$skip-video, #= skip video solution
    Bool :$debug, #= debug logs
) is export {
    my IO() $output = "%s/fornax-%s".sprintf(
        '/tmp', ('a'...'z', 'A'...'Z', 0...9).roll(8).join
    );
    mkdir $output;
    die "Output directory doesn't exist" unless $output.d;

    put "[fornax] Output: '$output'";

    my Str @lines = $input.IO.lines;
    my Int() %meta{Str} = Metadata.parse(@lines.first).Hash
                                  or die "Cannot parse metadata";

    constant %CANVAS = :1920width, :1080height;

    # Every cell must be square. Get the maximum width, height and use
    # that to decide which is to be used.
    my Int %cell = width => %CANVAS<width> div %meta<cols>,
                   height => %CANVAS<height> div %meta<rows>;

    my Int $side;
    my Int %excess = :0width, :0height;

    # Consider width if cells with dimension (width * width) fit
    # within the canvas, otherwise consider the height.
    if (%cell<width> * %meta<rows>) < %CANVAS<height> {
        %excess<height> = %CANVAS<height> - (%cell<width> * %meta<rows>);
        $side = %cell<width>;
    } else {
        %excess<width> = %CANVAS<width> - (%cell<height> * %meta<cols>);
        $side = %cell<height>;
    }

    my $render-start = now;
    my Int $total-frames = @lines.elems - 1;

    my Promise @p;
    for @lines.skip.kv -> $idx, $iter is rw {
        # Wait until all scheduled jobs are finished, then empty the
        # array and continue.
        if @p.elems == $batch {
            await @p;
            @p = [];

            print "\r";
            print "%s  Remaining: %.2fs  Elapsed: %.2fs %s".sprintf(
                "[fornax $idx/$total-frames]",
                ((now - $render-start) / $idx) * ($total-frames - $idx),
                now - $render-start, "        ",
            );
        }

        push @p, start {
            generate-frame(
                :%CANVAS, :%excess, :$side, :%meta, :$iter, :$idx, :$debug,
                :out("%s/%08d.png".sprintf: $output, $idx),
            );
        }
    }
    # Wait for remaining jobs to finish.
    await @p;

    print "\r";
    put "[fornax] Generated $total-frames frames in %.2fs. %s".sprintf(
        now - $render-start, " " x 16,
    );

    unless $skip-video {
        put "[fornax] Creating a slideshow.";

        my Str $log-level = $debug ?? "info" !! "error";
        run «ffmpeg -loglevel "$log-level" -r "$frame-rate" -i "$output/\%08d.png"
                    -vf 'tpad=stop_mode=clone:stop_duration=4'
                    -vcodec libx264 -crf 28 -pix_fmt yuv420p "$output/solution.mp4"»;
    }
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
