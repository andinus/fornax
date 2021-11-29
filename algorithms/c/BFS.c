#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#define ROWS 3
#define COLS 3

struct Queue {
    size_t front;
    size_t rear;
    size_t capacity;
    int *elems;
};

struct Queue *Q_initialize(size_t capacity) {
    if (capacity == 0)
        errx(1, "Capacity must be > 0");

    struct Queue *q = calloc(1, sizeof(*q));
    q->capacity = capacity;
    q->front = -1;
    q->rear = -1;
    q->elems = calloc(q->capacity, sizeof(*q->elems));
    return q;
}

void Q_destroy(struct Queue *q) {
    free(q->elems);
    free(q);
}

void Q_insert(struct Queue *q, int elem) {
    if (q->rear == q->capacity - 1)
        errx(1, "Overflow - Max Capacity");

    if (q->front == -1UL)
        q->front = 0;

    q->elems[++q->rear] = elem;
}

int Q_delete(struct Queue *q) {
    if (q->front == -1UL || q->front > q->rear)
        errx(1, "Underflow - Empty Queue");

    return q->elems[q->front++];
}

void
bfs(struct Queue *q_x, struct Queue *q_y,
    size_t x, size_t y, char maze[ROWS][COLS], bool visited[ROWS][COLS],
    size_t parent_path_x[ROWS][COLS], size_t parent_path_y[ROWS][COLS]) {
    int dir[4][4] = {
        {+0, +1}, // Right.
        {+1, +0}, // Down.
        {+0, -1}, // Left.
        {-1, +0}, // Up.
    };

    for (int idx = 0; idx < 4; idx++) {
        size_t cur_x = x + dir[idx][0];
        size_t cur_y = y + dir[idx][1];

        // Out of bounds check.
        if (cur_x < 0 || cur_y < 0
            || cur_x > ROWS - 1 || cur_y > COLS - 1)
            continue;

        // Found a solution, exiting.
        if (maze[cur_x][cur_y] == '$') {
            parent_path_x[cur_x][cur_y] = x;
            parent_path_y[cur_x][cur_y] = y;

            size_t loop_x = cur_x;
            size_t loop_y = cur_x;

            bool cur_path[ROWS][COLS] = { false };

            cur_path[0][0] = true;
            while (loop_x != 0 || loop_y != 0) {
                cur_path[loop_x][loop_y] = true;
                size_t tmp = loop_x;
                loop_x = parent_path_x[loop_x][loop_y];
                loop_y = parent_path_y[tmp][loop_y];
            }

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

        if (visited[cur_x][cur_y] || maze[cur_x][cur_y] == '#')
            continue;

        if (maze[cur_x][cur_y] == '.' || maze[cur_x][cur_y] == '^') {
            Q_insert(q_x, cur_x);
            Q_insert(q_y, cur_y);

            visited[cur_x][cur_y] = true;
            parent_path_x[cur_x][cur_y] = x;
            parent_path_y[cur_x][cur_y] = y;
        }
    }

    Q_delete(q_x);
    Q_delete(q_y);
    if (q_x->front == -1UL) {
        puts("Path not Found");
        exit(0);
    } else {
        bfs(q_x, q_y, q_x->elems[q_x->front], q_y->elems[q_x->front],
            maze, visited, parent_path_x, parent_path_y);
    }
}

int
main() {
    size_t capacity = 128;
    struct Queue *q_x = Q_initialize(capacity);
    struct Queue *q_y = Q_initialize(capacity);

    char maze[ROWS][COLS] = {
        { '^', '.', '.' },
        { '.', '#', '.' },
        { '.', '.', '$' },
    };

    bool visited[ROWS][COLS] = { false };
    size_t parent_path_x[ROWS][COLS] = { 0 };
    size_t parent_path_y[ROWS][COLS] = { 0 };

    visited[0][0] = true;
    bfs(q_x, q_y, 0, 0, maze, visited, parent_path_x, parent_path_y);

    Q_destroy(q_x);
    Q_destroy(q_y);
}
