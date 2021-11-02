use Cairo;

subset Directory of Str where *.IO.d;
proto MAIN(|) is export { unless so @*ARGS { put $*USAGE; exit }; {*} }

#| Collection of tools to visualize Path Finding Algorithms
multi sub MAIN(
    Str $script, #= script to run (e.g. java/DFS)
    Directory :$algorithms = 'algorithms', #= algorithms directory
    Directory :$output = 'output', #= output directory
) is export {
    my Str $interpreter = $script.split("/").first;
    my IO() $program-path = "$algorithms/$script.$interpreter";

    die "Program path invalid" unless $program-path.IO.f;

    my $proc = run «$interpreter $program-path», :out;
    my @out = $proc.out.slurp(:close).lines;

    my Int() $rows = @out[0].split(":")[0];
    my Int() $columns = @out[0].split(":")[1];

    my Int $c-width = 512;
    my Int $c-height = 512;

    for @out[1].split(" ", :skip-empty) -> $iter {
        my $file = "$output/" ~ $++ ~ ".svg";
        given Cairo::Surface::SVG.create($file, $c-width, $c-height) {
            given Cairo::Context.new($_) {
                my $COMPLETE = so $iter.comb.first eq "|";
                my @iter-corrected = $COMPLETE ?? $iter.comb.skip !! $iter.comb;
                my @grid = @iter-corrected.rotor: $columns;

                die "Invalid grid: $iter" unless @grid.elems == $rows;

                my $x-grid = $c-width / $rows;
                my $y-grid = $c-height / $columns;

                for ^$rows -> $r {
                    for ^$columns -> $c {
                        .rectangle($c * $y-grid, $r * $x-grid, $y-grid, $x-grid);

                        given @grid[$r][$c] -> $cell {
                            when $cell eq 'x' {
                                .rgba(192 / 255, 239 / 255, 255 / 255, 0.8);
                                .rgba(174 / 255, 207 / 255, 144 / 255, 1) if $COMPLETE;
                            }
                            when $cell eq '#' { .rgba(0, 0, 0, 0.5); }
                            when $cell eq '$' { .rgba(174 / 255, 207 / 255, 144 / 255, 1); }
                            when $cell eq '_' { .rgba(0, 0, 0, 0.1); }
                            default { .rgb(1, 0, 0); }
                        }
                        .fill :preserve;

                        .rgba(0, 0, 0, 0.6);
                        .rectangle($c * $y-grid, $r * $x-grid, $y-grid, $x-grid);
                        .stroke;
                    }
                }
            }
            .finish;
        }
    }
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
