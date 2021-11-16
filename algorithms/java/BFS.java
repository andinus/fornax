class Coordinates {
    // for storing coordinates as object.
    public int x, y;

    Coordinates(int x,int y) {
        this.x = x;
        this.y = y;
    }
}

public class BFS {
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
        if (front == 0 && rear == 0) {
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

    static void bfs(char[][] maze, Coordinates start, boolean[][] visited) {
        int curx;
        int cury;
        for (int i = 0; i < 4; i++) {
            curx = start.x;
            cury = start.y;

            curx += dir[i][0];
            cury += dir[i][1];

            if (curx < 0 || cury < 0 || curx > maze.length - 1 || cury > maze.length - 1) {
                // for square...  out of maze check.
                continue;
            } else if (maze[curx][cury] == '$') {
                System.out.println("Path found");
                System.exit(0);
            } else if (visited[curx][cury] || maze[curx][cury] == '#') {
                continue;
            } else if(maze[curx][cury]=='_') {
                enqueue(new Coordinates(curx, cury));
                visited[curx][cury] = true;
            }
        }
        dequeue();
        if (front == -1) {
            System.out.println("path not found");
            System.exit(0);
        } else
            bfs(maze, queue[front], visited);
    }

    public static void main(String[] args) {
        char[][] maze = {
            {'*', '#', '#'},
            {'_', '_', '#'},
            {'_', '#', '$'},
        };

        Coordinates start = new Coordinates(0,0);
        boolean[][] visited = new boolean[maze.length][maze.length];

        for (int i = 0; i < maze.length; i++) {
            for (int j = 0; j < maze.length; j++) {
                visited[i][j] = false;
            }
        }

        visited[0][0] = true;
        enqueue(start);
        bfs(maze, start, visited);
    }
}
