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

    # Consider width if cells with dimension (width * width) fit
    # within the canvas, otherwise consider the height.
    if (%cell<width> * %meta<rows>) < %CANVAS<height> {
        %cell<height> = %cell<width>;
    } else {
        %cell<width> = %cell<height>;
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

        put "$idx $iter $status";

        my @grid = $iter.comb.rotor: %meta<cols>;
        warn "Invalid grid: $idx $iter $status" unless @grid.elems == %meta<rows>;

        given Cairo::Image.create(
            Cairo::FORMAT_ARGB32, %CANVAS<width>, %CANVAS<height>
        ) {
            given Cairo::Context.new($_) {
                # Paint the entire canvas white.
                .rgb: |%C<white>;
                .rectangle(0, 0, %CANVAS<width>, %CANVAS<height>);
                .fill :preserve;
                .stroke;

                for ^%meta<rows> -> $r {
                    for ^%meta<cols> -> $c {
                        .rectangle($c * %cell<height>, $r * %cell<width>, %cell<height>, %cell<width>);

                        given @grid[$r][$c] -> $cell {
                            when $cell eq $VIS|$CUR {
                                .rgba: |%C<cyan>, 0.8;
                                .rgba: |%C<green>, 0.8 if $status == Completed;
                                .rgba: |%C<red>, 0.8 if $status == Blocked;
                            }
                            when $cell eq $BLOK { .rgba: |%C<black>, 0.5 }
                            when $cell eq $DEST { .rgb: |%C<green> }
                            default { .rgb: |%C<white> }
                        }
                        .fill :preserve;

                        .rgb: |%C<black>;
                        .rectangle($c * %cell<height>, $r * %cell<width>, %cell<height>, %cell<width>);
                        .stroke;
                    }
                }
            }
            .write_png("%s/%08d.png".sprintf: $output, $idx);
            .finish;
        }
    }
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
