class BFS {
    // queue of coordinates.
    static Coordinates[] queue = new Coordinates[1000];
    private static int front = -1;
    private static int rear = -1;

    static void enqueue(Coordinates coord) {
        if (front == -1 && rear == -1) {
            front = 0;
            rear = 0;
        } else {
            rear++;
        }
        queue[rear] = coord;
    }

    static void dequeue() {
        if (front == rear) {
            front = -1;
            rear = -1;
        } else {
            front++;
        }
    }

    // traversing directions.
    private static final int[][] dir = new int[][]{
        {+0, +1}, // right.
        {+1, +0}, // down.
        {+0, -1}, // left.
        {-1, +0}, // up.
    };

    static void bfs(char[][] maze, Coordinates start, boolean[][] visited,Coordinates [][] path) {
        for (int i = 0; i < 4; i++) {
            int curx = start.x + dir[i][0];
            int cury = start.y + dir[i][1];

            // Out of bounds check.
            if (curx < 0 || cury < 0
                || curx > maze.length - 1 || cury > maze[0].length - 1)
                continue;

            // Marker cell.
            if (maze[curx][cury] == '#')
                System.out.print("!");

            // Print the maze on every iteration.
            for(int j = 0; j < maze.length; j++)
                for(int k = 0; k < maze[j].length; k++) {
                    if (maze[j][k] == '^' || maze[j][k] == '$')
                        System.out.print(maze[j][k]);
                    else {
                        if (j == curx && k == cury)
                            System.out.print("@");
                        else {
                            if (visited[j][k])
                                System.out.print("-");
                            else
                                System.out.print(maze[j][k]);
                        }
                    }
                }
            System.out.println();
            if (maze[curx][cury] == '$') {
                path[curx][cury] = new Coordinates(start.x,start.y);

                boolean[][] printpath = new boolean[maze.length][maze[0].length];

                for (int q = 0; q < maze.length; q++) {
                    for (int j = 0; j < maze[q].length; j++) {
                        printpath[q][j] = false;
                    }
                }

                printpath[0][0]=true;                   //start as true
                while(curx != 0 || cury != 0){
                    printpath[curx][cury] = true;
                    int temp = curx;
                    curx = path[curx][cury].x;
                    cury = path[temp][cury].y;

                    //path stores parent of current coordinate
                }

                // Marker cell.
                System.out.print("|");
                for(int j = 0; j < maze.length; j++)
                    for(int k = 0; k < maze[j].length; k++) {
                        if (maze[j][k] == '^' || maze[j][k] == '$')
                            System.out.print(maze[j][k]);
                        else {
                            if (j == curx && k == cury)
                                System.out.print("@");
                            else {
                                if(printpath[j][k])
                                    System.out.print("~");
                                else if (visited[j][k])
                                    System.out.print("-");
                                else
                                    System.out.print(maze[j][k]);
                            }
                        }
                    }
                System.out.println();
                System.exit(0);
            } else if (visited[curx][cury] || maze[curx][cury] == '#') {
                continue;
            } else if(maze[curx][cury]=='.') {
                enqueue(new Coordinates(curx, cury));
                visited[curx][cury] = true;
                path[curx][cury]=new Coordinates(start.x,start.y);
            }
        }
        dequeue();
        if (front == -1) {
            System.out.println("path not found");
            System.exit(0);
        } else {
            bfs(maze, queue[front], visited, path);
        }
    }

    public static void main(String[] args) {
        char[][] maze = {
            { '^', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '#', '#', '#', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '#', '#', '.', '#', '.', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '.', '#', '.', '#', '#', '.', '#', '#', '#', },
            { '.', '.', '.', '.', '.', '#', '.', '#', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '.', '#', '.', '#', '.', '.', '.', '$', '.', },
            { '.', '.', '.', '.', '.', '#', '.', '#', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '.', '.', '.', '#', '.', '.', '.', '.', '.', },
            { '.', '.', '.', '.', '.', '#', '.', '.', '.', '.', '.', '.', '.', },
            // {'^', '#', '.'},
            // {'.', '.', '#'},
            // {'.', '.', '$'},
        };

        Coordinates start = new Coordinates(0,0);
        boolean[][] visited = new boolean[maze.length][maze[0].length];
        Coordinates[][] path = new Coordinates[maze.length][maze[0].length];

        System.out.println(String.format("rows:%d cols:%d", maze.length, maze[0].length));

        for (int i = 0; i < maze.length; i++)
            for (int j = 0; j < maze[i].length; j++) {
                visited[i][j] = false;
                path[i][j] = new Coordinates(0, 0);
                System.out.print(maze[i][j]);
            }
        System.out.println();

        visited[0][0] = true;
        enqueue(start);
        bfs(maze, start, visited,path);
    }
}

class Coordinates {
    // for storing coordinates as object.
    public int x, y;

    Coordinates(int x,int y) {
        this.x = x;
        this.y = y;
    }
}
