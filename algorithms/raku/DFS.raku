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

# neighbors returns the neighbors of given index. Neighbors are cached
# in @neighbors array. This way we don't have to compute them
# everytime neighbors subroutine is called for the same position. We
# don't need this caching here since every cell will be visited only
# once. This subroutine was taken from Octans::Neighbors.
sub neighbors(
    @puzzle, Int $y, Int $x --> List
) is export {
    # @directions is holding a list of directions we can move in. It's
    # used later for neighbors subroutine.
    state List @directions = (
        # $y, $x
        ( +1, +0 ), # bottom
        ( -1, +0 ), # top
        ( +0, +1 ), # left
        ( +0, -1 ), # right
    );

    # @neighbors holds the neighbors of given position.
    state Array @neighbors;

    if @puzzle[$y][$x] {
        # Don't re-compute neighbors.
        unless @neighbors[$y][$x] {
            # Set it to an empty array because otherwise if it has no
            # neighbors then it would've be recomputed everytime
            # neighbors() was called.
            @neighbors[$y][$x] = [];

            my Int $pos-x;
            my Int $pos-y;

            # Starting from the intital position of $y, $x we move to
            # each direction according to the values specified in
            # @directions array. In this case we're just trying to
            # move in 4 directions (top, bottom, left & right).
            direction: for @directions -> $direction {
                $pos-y = $y + $direction[0];
                $pos-x = $x + $direction[1];

                # If movement in this direction is out of puzzle grid
                # boundary then move on to next direction.
                next direction unless @puzzle[$pos-y][$pos-x];

                # If neighbors exist in this direction then add them
                # to @neighbors[$y][$x] array.
                push @neighbors[$y][$x], [$pos-y, $pos-x];
            }
        }
    } else {
        # If it's out of boundary then return no neighbor.
        @neighbors[$y][$x] = [];
    }

    return @neighbors[$y][$x];
}
