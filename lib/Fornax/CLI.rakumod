use Cairo;
use Fornax::Hex2RGB;

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
    Bool :$verbose = True, #= verbosity (default: True)
) is export {
    my IO() $output = "%s/fornax-%s".sprintf(
        '/tmp', ('a'...'z', 'A'...'Z', 0...9).roll(8).join
    );
    mkdir $output;
    die "Output directory doesn't exist" unless $output.d;

    put "[fornax] Output: '$output'" if $verbose;

    my Str @lines = $input.IO.lines;
    my Int() %meta{Str} = Metadata.parse(@lines.first).Hash
                             or die "Cannot parse metadata";

    # Cells as defined by fornax format.
    constant $PATH = '.';
    constant $BLOK = '#';
    constant $DEST = '$';
    constant $STRT = '^';
    constant $VIS = '-';
    constant $CUR = '@';
    constant $CURPATH = '~';

    constant %CANVAS = :1920width, :1080height;

    # Colors.
    constant %C = (
        bg-main => "#ffffff",

        red-subtle-bg => "#f2b0a2",
        blue-subtle-bg => "#b5d0ff",
        cyan-subtle-bg => "#c0efff",
        green-subtle-bg => "#aecf90",

        fg-main => "#000000",

        fg-special-cold => "#093060",
        fg-special-warm => "#5d3026",
        fg-special-mild => "#184034",
        fg-special-calm => "#61284f",
    ).map: {.key => hex2rgb(.value)};

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

    enum IterStatus <Walking Blocked Completed>;

    my Promise @p;
    for @lines.skip.kv -> $idx, $iter is rw {
        # Wait until all scheduled jobs are finished, then empty the
        # array and continue.
        if @p.elems == $batch {
            await @p;
            @p = [];
        }

        push @p, start {
            my IterStatus $status;
            given $iter.substr(0, 1) {
                when '|' { $status = Completed }
                when '!' { $status = Blocked }
                default { $status = Walking }
            };

            # Remove marker.
            $iter .= substr(1) if $status == Completed|Blocked;

            put "[fornax] $idx $iter $status" if $verbose;

            my @grid = $iter.comb.rotor: %meta<cols>;
            warn "Invalid grid: $idx $iter $status" unless @grid.elems == %meta<rows>;

            given Cairo::Image.create(
                Cairo::FORMAT_ARGB32, %CANVAS<width>, %CANVAS<height>
            ) {
                given Cairo::Context.new($_) {
                    # Paint the entire canvas white.
                    .rgb: |%C<bg-main>;
                    .rectangle(0, 0, %CANVAS<width>, %CANVAS<height>);
                    .fill;

                    for ^%meta<rows> -> $r {
                        for ^%meta<cols> -> $c {
                            my Int @target = %excess<width> div 2 + $c * $side,
                                             %excess<height> div 2 + $r * $side,
                                             $side, $side;

                            .rectangle: |@target;

                            given @grid[$r][$c] -> $cell {
                                # According to the format, current
                                # position may be prioritized over
                                # Destination symbol so we colorize it
                                # according to $status.
                                when $cell eq $CUR {
                                    .rgba: |%C<fg-special-cold>, 0.56;
                                    .rgba: |%C<fg-special-mild>, 0.72 if $status == Completed;
                                    .rgba: |%C<fg-special-warm>, 0.72 if $status == Blocked;
                                }
                                when $cell eq $CURPATH {
                                    .rgba: |%C<blue-subtle-bg>, 0.84;
                                    .rgba: |%C<green-subtle-bg>, 0.96 if $status == Completed;
                                    .rgba: |%C<red-subtle-bg>, 0.96 if $status == Blocked;
                                }
                                when $cell eq $VIS {
                                    .rgba: |%C<cyan-subtle-bg>, 0.72;
                                }
                                when $cell eq $BLOK { .rgba: |%C<fg-main>, 0.56 }
                                when $cell eq $STRT|$DEST { .rgba: |%C<fg-special-mild>, 0.72 }
                                default { .rgba: |%C<fg-main>, 0.08 }
                            }
                            .fill :preserve;

                            .rgb: |%C<fg-main>;
                            .stroke;
                        }
                    }
                }
                .write_png("%s/%08d.png".sprintf: $output, $idx);
                .finish;
            }
        }
    }
    # Wait for remaining jobs to finish.
    await @p;

    put "[fornax] Generated images." if $verbose;

    unless $skip-video {
        put "[fornax] Creating a slideshow." if $verbose;

        my Str $log-level = $verbose ?? "info" !! "error";
        run «ffmpeg -loglevel "$log-level" -r "$frame-rate" -i "$output/\%08d.png"
                    -vf 'tpad=stop_mode=clone:stop_duration=4'
                    -vcodec libx264 -crf 28 -pix_fmt yuv420p "$output/solution.mp4"»;
    }
    put "[fornax] Output: '$output'";
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
