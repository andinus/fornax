public class CG_pathfinder {
    static int paths = 0;

    private static final int[][] dir = new int[][]{
        {0, 1}, //right
        {1, 0}, //down
        {0, -1}, //left
        {-1, 0} //up
    };

    static void traverse(int x, int y, char[][] maze, boolean[][] visited) {
        int curx;
        int cury;
        for (int i = 0; i < 4; i++) {
            // Print the maze at every iteration.
            for(int j = 0; j < maze.length; j++)
                for(int k = 0; k < maze[j].length; k++)
                    if (visited[j][k])
                        System.out.print("x");
                    else
                        System.out.print(maze[j][k]);
            System.out.print(" ");

            curx = x;
            cury = y;

            curx += dir[i][0];
            cury += dir[i][1];

            if (curx < 0 || cury < 0
                || curx > maze.length - 1 || cury > maze.length - 1)
                continue; //optional?       //for square mazes

            if (maze[curx][cury] == '$') {
                paths++;
                System.out.print("|");
                // Print the maze at every iteration.
                for(int j = 0; j < maze.length; j++)
                    for(int k = 0; k < maze[j].length; k++)
                        if (visited[j][k])
                            System.out.print("x");
                        else
                            System.out.print(maze[j][k]);
                System.out.print(" ");
            } else if (maze[curx][cury] == 'x' || visited[curx][cury])
                continue;
            else if (maze[curx][cury] == '_') {
                visited[curx][cury] = true;
                traverse(curx, cury, maze, visited);
                visited[curx][cury] = false;
            }
        }
    }

    public static void main(String[] args) {
        char[][] maze = {
            {'*', '#', '_'},
            {'_', '_', '_'},
            {'_', '_', '$'}
        };

        int[] start = {0, 0};
        boolean[][] visited = new boolean[maze.length][maze[0].length];
        for (int i = 0; i< maze.length; i++)
            for (int j = 0; j<maze.length; j++)
                visited[i][j] = false;

        System.out.println(String.format("%d:%d", maze.length, maze[0].length));
        visited[0][0] = true;
        traverse(start[0], start[1], maze, visited);
        System.out.println();
    }
}
