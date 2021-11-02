use Cairo;

subset Directory of Str where *.IO.d;

#| Collection of tools to visualize Path Finding Algorithms
unit sub MAIN(
    Str $script, #= script to run (e.g. java/DFS)
    Directory :$algorithms = 'algorithms/', #= algorithms directory
);

my Str $interpreter = $script.split("/").first;
my IO() $program-path = $algorithms ~ $script ~ '.' ~ $interpreter;

die "Program path invalid" unless $program-path.IO.f;
