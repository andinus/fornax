use Cairo;

subset Directory of Str where *.IO.d;
proto MAIN(|) is export { unless so @*ARGS { say $*USAGE; exit }; {*} }

#| Collection of tools to visualize Path Finding Algorithms
multi sub MAIN(
    Str $script, #= script to run (e.g. java/DFS)
    Directory :$algorithms = 'algorithms/', #= algorithms directory
) is export {
    my Str $interpreter = $script.split("/").first;
    my IO() $program-path = $algorithms ~ $script ~ '.' ~ $interpreter;

    die "Program path invalid" unless $program-path.IO.f;
}

multi sub MAIN(
    Bool :$version #= print version
) { say "Fornax v" ~ $?DISTRIBUTION.meta<version>; }
