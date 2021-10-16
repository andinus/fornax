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
            curx = x;
            cury = y;

            curx += dir[i][0];
            cury += dir[i][1];

            if (curx < 0 || cury < 0
                || curx > maze.length - 1 || cury > maze.length - 1)
                continue; //optional?       //for square mazes

            if (maze[curx][cury] == '$') {
                System.out.println("Path Found");
                paths++;
                for(int k = 0; k < maze.length; k++) {
                    for(int j = 0; j < maze.length; j++)
                        System.out.print(visited[k][j]);
                    System.out.println();
                }
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
            {'*', '#', 'x'},
            {'_', '_', '_'},
            {'_', '_', '$'}
        };
        int[] start = {0, 0};

        System.out.println("Solving for the maze: ");
        boolean[][] visited = new boolean[maze.length][maze.length];

        for (int i = 0; i<maze.length; i++){
            for (int j = 0; j<maze[i].length; j++)
                System.out.print(maze[i][j] + " "); // Printing maze
            System.out.println("");
        }

        for (int i = 0; i< maze.length; i++)
            for (int j = 0; j<maze.length; j++)
                visited[i][j] = false;

        visited[0][0] = true;
        traverse(start[0], start[1], maze, visited);
        if (paths == 0)
            System.out.println("no paths found");
        else
            System.out.println(paths);
    }
}
