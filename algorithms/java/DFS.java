public class DFS {
    static int[][] directions = new int[][]{
        {+0, +1}, // Right.
        {+1, +0}, // Down.
        {+0, -1}, // Left.
        {-1, +0}, // Up.
    };

    static void traverse(int x, int y, char[][] maze, boolean[][] visited) {
        for (int i = 0; i < 4; i++) {
            int curx = x + directions[i][0];
            int cury = y + directions[i][1];

            // Out of bounds check.
            if (curx < 0 || cury < 0
                || curx > maze.length - 1 || cury > maze.length - 1)
                continue;

            // Marker cells.
            if (maze[curx][cury] == '$')
                System.out.print("|");
            else if (maze[curx][cury] == '#')
                System.out.print("!");

            // Print the maze on every iteration.
            for(int j = 0; j < maze.length; j++)
                for(int k = 0; k < maze[j].length; k++)
                    if (j == curx && k == cury)
                        System.out.print("@");
                    else
                        System.out.print(visited[j][k] ? "-" : maze[j][k]);
            System.out.println();

            // Found a solution, exiting.
            if (maze[curx][cury] == '$')
                System.exit(0);

            if (visited[curx][cury]) {
                continue;
            } else if (maze[curx][cury] == '.') {
                visited[curx][cury] = true;
                traverse(curx, cury, maze, visited);
                visited[curx][cury] = false;
            }
        }
    }

    public static void main(String[] args) {
        char[][] maze = {
            {'.', '#', '.'},
            {'.', '.', '.'},
            {'.', '.', '$'}
        };

        boolean[][] visited = new boolean[maze.length][maze[0].length];

        for (int i = 0; i < maze.length; i++)
            for (int j = 0; j < maze[i].length; j++)
                visited[i][j] = false;

        System.out.println(String.format("rows:%d cols:%d", maze.length, maze[0].length));

        // Print the maze.
        for(int j = 0; j < maze.length; j++)
            for(int k = 0; k < maze[j].length; k++)
                    System.out.print(maze[j][k]);
        System.out.println();

        // Start at 0,0.
        visited[0][0] = true;
        traverse(0, 0, maze, visited);
    }
}
