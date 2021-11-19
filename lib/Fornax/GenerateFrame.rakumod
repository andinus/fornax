use Cairo;
use Fornax::Hex2RGB;

# Cells as defined by fornax format.
constant $PATH = '.';
constant $BLOK = '#';
constant $DEST = '$';
constant $STRT = '^';
constant $VIS = '-';
constant $CUR = '@';
constant $CURPATH = '~';

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

enum IterStatus <Walking Blocked Completed>;

sub generate-frame(
    :%CANVAS, :$out, :%excess, :$side, :%meta, :$iter is copy
    , :$idx, :$debug,
) is export {
    my IterStatus $status;
    given $iter.substr(0, 1) {
        when '|' { $status = Completed }
        when '!' { $status = Blocked }
        default { $status = Walking }
    };

    # Remove marker.
    $iter .= substr(1) if $status == Completed|Blocked;

    put "\n[fornax] $idx $iter $status" if $debug;

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

            # This seems to be slower than creating an intermediate
            # variable and assigning from that. Difference is not much
            # so we'll ignore it.
            for ^%meta<rows> X ^%meta<cols>  -> ($r, $c) {
                my Int @target = %excess<width> div 2 + $c * $side,
                                 %excess<height> div 2 + $r * $side,
                                 $side, $side;

                .rectangle: |@target;

                given @grid[$r][$c] -> $cell {
                    # According to the format, current position may be
                    # prioritized over Destination symbol so we
                    # colorize it according to $status.
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
        .write_png($out);
        .finish;
    }
}
