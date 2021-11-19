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
            int curx = start.x;
            int cury = start.y;

            curx += dir[i][0];
            cury += dir[i][1];
            
            if (curx < 0 || cury < 0 || curx > maze.length - 1 || cury > maze.length - 1) {
                // for square...  out of maze check.
                continue;
            } 
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
                path[curx][cury]=new Coordinates(start.x,start.y);

                System.out.println("Path found");
                
                boolean[][] printpath=new boolean[maze.length][maze.length];
                for (int q = 0; q < maze.length; q++) {
                    for (int j = 0; j < maze.length; j++) {
                       printpath[q][j]=false;
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
                for(int d=0;d<maze.length;d++){
                    for(int e=0;e<maze.length;e++){
                        System.out.print(printpath[d][e]);                  //print path
                    }
                    System.out.println();
                }
                System.exit(0);
            } else if (visited[curx][cury] || maze[curx][cury] == '#') {
                continue;
            } else if(maze[curx][cury]=='_') {
                enqueue(new Coordinates(curx, cury));
                visited[curx][cury] = true;
                path[curx][cury]=new Coordinates(start.x,start.y);
            }
        }
        dequeue();
        if (front == -1) {
            System.out.println("path not found");
            System.exit(0);
        } else{
           
         //   System.out.println(start.x + " " + start.y);
            bfs(maze, queue[front], visited, path);
        }
    }

    public static void main(String[] args) {
        char[][] maze = {
            {'*', '#', '_'},
            {'_', '_', '#'},
            {'_', '_', '$'},
        };

        Coordinates start = new Coordinates(0,0);
        boolean[][] visited = new boolean[maze.length][maze.length];
        Coordinates[][] path = new Coordinates[maze.length][maze.length];

        for (int i = 0; i < maze.length; i++) {
            for (int j = 0; j < maze.length; j++) {
                visited[i][j] = false;
                path[i][j] = new Coordinates(0, 0);
            }
        }

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
