#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define ROWS 3
#define COLS 3

void
dfs(size_t x, size_t y, char maze[ROWS][COLS], bool visited[ROWS][COLS],
    bool cur_path[ROWS][COLS]) {
    int dir[4][4] = {
        {+0, +1}, // Right.
        {+1, +0}, // Down.
        {+0, -1}, // Left.
        {-1, +0}, // Up.
    };

    for (int idx = 0; idx < 4; idx++) {
        size_t cur_x = x + dir[idx][0];
        size_t cur_y = y + dir[idx][1];

        // Outn of bounds check.
        if (cur_x < 0 || cur_y < 0
            || cur_x > ROWS - 1 || cur_y > COLS - 1)
            continue;

        if (visited[cur_x][cur_y])
            continue;

        // Found a solution, exiting.
        if (maze[cur_x][cur_y] == '$') {
            for (size_t j = 0; j < ROWS; j++) {
                for (size_t k = 0; k < COLS; k++) {
                    if (maze[j][k] == '^' || maze[j][k] == '$')
                        printf("%c", maze[j][k]);
                    else {
                        if (j == cur_x && k == cur_y)
                            printf("@");
                        else {
                            if (cur_path[j][k])
                                printf("~");
                            else if (visited[j][k])
                                printf("-");
                            else
                                printf("%c", maze[j][k]);
                        }
                    }
                    printf(" ");
                }
                printf("\n");
            }
            exit(0);
        }

        if (maze[cur_x][cur_y] == '.' || maze[cur_x][cur_y] == '^') {
            visited[cur_x][cur_y] = cur_path[cur_x][cur_y] = true;
            dfs(cur_x, cur_y, maze, visited, cur_path);
            cur_path[cur_x][cur_y] = false;
        }
    }
}

int
main() {
    char maze[ROWS][COLS] = {
        { '^', '.', '.' },
        { '.', '#', '.' },
        { '.', '.', '$' },
    };

    bool visited[ROWS][COLS] = { false };
    bool cur_path[ROWS][COLS] = { false };

    visited[0][0] = true;
    cur_path[0][0] = true;
    dfs(0, 0, maze, visited, cur_path);
}
