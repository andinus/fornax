use Cairo;
use Fornax::Hex2RGB;

subset File of Str where *.IO.f;
subset Directory of Str where *.IO.d;

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
    Directory :$output = 'output', #= output directory (existing)
    Int :$frame-rate = 1, #= frame rate
    Bool :$verbose = True, #= verbosity
) is export {
    my Str @lines = $input.IO.lines;
    my Int() %meta{Str} = Metadata.parse(@lines.first).Hash
                             or die "Cannot parse metadata";

    # Cells as defined by fornax format.
    constant $PATH = '.';
    constant $BLOK = '#';
    constant $DEST = '$';
    constant $VIS = '-';
    constant $CUR = '@';

    constant %CANVAS = :1920width, :1080height;

    # Colors.
    constant %C = (
        black => "#000000",
        white => "#ffffff",
        green => "#aecf90",
        cyan => "#c0efff",
        red => "#f2b0a2",
        pointer => "#093060"
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
        %excess<height> = abs %CANVAS<width> - %CANVAS<height>;
        $side = %cell<width>;
    } else {
        %excess<width> = abs %CANVAS<width> - %CANVAS<height>;
        $side = %cell<height>;
    }

    enum IterStatus <Walking Blocked Completed>;

    for @lines.skip.kv -> $idx, $iter is rw {
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
                .rgb: |%C<white>;
                .rectangle(0, 0, %CANVAS<width>, %CANVAS<height>);
                .fill;
                .stroke;

                for ^%meta<rows> -> $r {
                    for ^%meta<cols> -> $c {
                        my Int @target = %excess<width> div 2 + $c * $side,
                                         %excess<height> div 2 + $r * $side,
                                         $side, $side;

                        .rectangle: |@target;
                        given @grid[$r][$c] -> $cell {
                            when $cell eq $VIS|$CUR {
                                .rgba: |%C<cyan>, 0.64;
                                .rgba: |%C<green>, 0.96 if $status == Completed;
                                .rgba: |%C<red>, 0.96 if $status == Blocked;
                            }
                            when $cell eq $BLOK { .rgba: |%C<black>, 0.48 }
                            when $cell eq $DEST { .rgb: |%C<green> }
                            default { .rgba: |%C<black>, 0.08 }
                        }
                        .fill :preserve;

                        .rgb: |%C<black>;
                        .rectangle: |@target;
                        .stroke;
                    }
                }
            }
            .write_png("%s/%08d.png".sprintf: $output, $idx);
            .finish;
        }
    }

    put "[fornax] Generated images.";
    put "[fornax] Creating a slideshow.";
    run «ffmpeg -loglevel error -r "$frame-rate" -i "$output/\%08d.png"
                -vcodec libx264 -crf 28 -pix_fmt yuv420p "$output/solution.mp4"»;
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
