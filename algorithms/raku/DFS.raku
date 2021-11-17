use Octans::Neighbors;

subset File of Str where *.IO.f;

# Cells as defined by fornax format.
constant $PATH = '.';
constant $BLOK = '#';
constant $DEST = '$';
constant $STRT = '^';
constant $VIS = '-';
constant $CUR = '@';
constant $CURPATH = '~';

sub MAIN(File $input) {
    my @maze = $input.IO.lines.map(*.comb);
    die "Inconsistent maze" unless [==] @maze.map(*.elems);

    put "rows:{@maze.elems} cols:{@maze[0].elems}";
    dfs(@maze, 0, 0);
}

sub dfs(
    @maze, Int $y, Int $x, @visited?, @cur-path? --> Bool
) {
    # If @visited was not passed then mark the given cell as visited
    # because it's the cell we're starting at.
    @visited[$y][$x] = True unless @visited;
    @cur-path[$y][$x] = True unless @cur-path;

    # neighbor block loops over the neighbors of $y, $x.
    neighbor: for neighbors(@maze, $y, $x).List.pick(*) -> $pos {
        # Move on to next neighbor if we've already visited this one.
        next neighbor if @visited[$pos[0]][$pos[1]];

        # Printing Marker cells.
        given @maze[$pos[0]][$pos[1]] {
            when $DEST { print "|" }
            when $BLOK { print "!" }
        }

        # Print the maze on every iteration.
        for 0..@maze.end -> $j {
            for 0..@maze[0].end -> $k {
                if @maze[$j][$k] eq $STRT | $DEST {
                    print @maze[$j][$k];
                } else {
                    if $j == $pos[0] and $k == $pos[1] {
                        print "@";
                    } else {
                        print(
                            @cur-path[$j][$k]
                            ?? "~" !! @visited[$j][$k] ?? "-" !! @maze[$j][$k]
                        );
                    }
                }
            }
        }
        print "\n";

        given @maze[$pos[0]][$pos[1]] {
            when $DEST { exit; }
            when $PATH|$STRT {
                @visited[$pos[0]][$pos[1]] = @cur-path[$pos[0]][$pos[1]] = True;
                dfs(@maze, $pos[0], $pos[1], @visited, @cur-path);
                @cur-path[$pos[0]][$pos[1]] = False;
            }
        }
    }
}
