/*
* EcoMender Bot (EB): Task 2B Path Planner
*
* This program computes the valid path from the start point to the end point.
* The flood-fill algorithm is used to compute the shortest path.
*
* In this modified version, instead of allocating 31 memory locations starting
* from 0x020000dc for a boolean visited array, we use a single 32-bit bitmask
* to mark the visited nodes. Each bit in the bitmask represents one node.
*
* Make sure you don't change anything outside the "Add your code here" section.
*/
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#define V 32

#ifdef __linux__  // for host PC
    #include <stdio.h>

    void _put_byte(char c) { putchar(c); }

    void _put_str(char *str) {
        while (*str) {
            _put_byte(*str++);
        }
    }

    void print_output(uint8_t num) {
        if (num == 0) {
            putchar('0'); // if the number is 0, directly print '0'
            _put_byte('\n');
            return;
        }
        char buffer[20];  // enough to hold 32-bit integer digits
        uint8_t index = 0;
        while (num > 0) {
            buffer[index++] = '0' + num % 10;
            num /= 10;
        }
        while (index > 0) { putchar(buffer[--index]); }
        _put_byte('\n');
    }

    void _put_value(uint8_t val) { print_output(val); }
#else  // for the test device
    void _put_value(uint8_t val) { }
    void _put_str(char *str) { }
#endif

// Flood-fill algorithm to compute the shortest path.
uint8_t flood_fill(uint8_t start, uint8_t end, uint32_t *graph, uint8_t *path_planned, uint8_t idx) {
#ifdef __linux__
    // Instead of a 32-element boolean array (32 bytes), we use a single 32-bit mask (4 bytes)
    uint32_t visitedMask = 0;
    uint8_t parent[V];
    uint8_t queue[V];
#else
    // Instead of reserving 31 memory locations starting at 0x020000dc for a boolean array,
    // we now reserve a single 32-bit bitmask to track visited nodes.
    uint32_t *visitedMask_ptr = (uint32_t *)0x020000dc;
    *visitedMask_ptr = 0;  // initialize the bitmask to 0 (no nodes visited)
    #define visitedMask (*visitedMask_ptr)
    uint8_t *parent = (uint8_t *)0x020000b0;
    uint8_t *queue = (uint8_t *)0x02000090;
#endif

    // Initialize the parent array. Use 255 to represent a "null" parent.
    for (int i = 0; i < V; ++i) {
        parent[i] = 255;
    } 

    uint8_t front = 0, rear = 0;
    queue[rear++] = start;
    // Mark the start node as visited by setting its corresponding bit.
#ifdef __linux__
    visitedMask |= (1 << start);
#else
    visitedMask |= (1 << start);
#endif

    while (front < rear) {
        uint8_t current = queue[front++];
        for (uint8_t neighbor = 0; neighbor < V; ++neighbor) {
            // Check if the neighbor is not visited and is connected to the current node.
            if (!(visitedMask & (1 << neighbor)) && (graph[current] & (1 << neighbor))) {
                visitedMask |= (1 << neighbor);  // Mark neighbor as visited.
                parent[neighbor] = current;
                queue[rear++] = neighbor;
                // If the end node is reached, break early.
                if (neighbor == end) {
                    front = rear; // Exit the while loop.
                    break;
                }
            }
        }
    }

    // Reconstruct the path using the parent array.
    uint8_t current = end;
    while (current != start) {
        path_planned[idx++] = current;
        current = parent[current];
    }
    path_planned[idx++] = start;

    // Reverse the path so it is in order from start to end.
    for (uint8_t i = 0; i < idx / 2; i++) {
        uint8_t temp = path_planned[i];
        path_planned[i] = path_planned[idx - 1 - i];
        path_planned[idx - 1 - i] = temp;
    }
    return idx;
}

// Main function.
int main(int argc, char const *argv[]) {
#ifdef __linux__
    if (argc < 3) {
        _put_str("Usage: <program> <START_POINT> <END_POINT>\n");
        return 1;
    }
    const uint8_t START_POINT = (uint8_t)atoi(argv[1]);
    const uint8_t END_POINT   = (uint8_t)atoi(argv[2]);
    uint8_t NODE_POINT = 0;
    uint8_t CPU_DONE = 0;
#else
    #define START_POINT         (* (volatile uint8_t * ) 0x02000000)
    #define END_POINT           (* (volatile uint8_t * ) 0x02000004)
    #define NODE_POINT          (* (volatile uint8_t * ) 0x02000008)
    #define CPU_DONE            (* (volatile uint8_t * ) 0x0200000c)
#endif

#ifdef __linux__
    uint32_t graph[V] = {
        0b00000000000000000000010001000010, // NODE 0
        0b00000000000000000000100000000101, // NODE 1
        0b00000000000000000000000000111010, // NODE 2
        0b00000000000000000000000000000100, // NODE 3
        0b00000000000000000000000000000100, // NODE 4
        0b00000000000000000000000000000100, // NODE 5
        0b00000000000000000000001110000001, // NODE 6
        0b00000000000000000000000001000000, // NODE 7
        0b00000000000000000000000001000000, // NODE 8
        0b00000000000000000000000001000000, // NODE 9
        0b00000101000000000000000000000001, // NODE 10
        0b00000000000010000001000000000010, // NODE 11
        0b00000000000000000110100000000000, // NODE 12
        0b00000000000000000001000000000000, // NODE 13
        0b00000000000000011001000000000000, // NODE 14
        0b00000000000000000100000000000000, // NODE 15
        0b00000000000001100100000000000000, // NODE 16
        0b00000000000000010000000000000000, // NODE 17
        0b00000000001010010000000000000000, // NODE 18
        0b00000000000101000000100000000000, // NODE 19
        0b00000000000010000000000000000000, // NODE 20
        0b00000000110001000000000000000000, // NODE 21
        0b00000000001000000000000000000000, // NODE 22
        0b01000001001000000000000000000000, // NODE 23
        0b00000010100000000000010000000000, // NODE 24
        0b00000001000000000000000000000000, // NODE 25
        0b00011000000000000000010000000000, // NODE 26
        0b00000100000000000000000000000000, // NODE 27
        0b01100100000000000000000000000000, // NODE 28 
        0b00010000000000000000000000000000, // NODE 29
        0b10010000100000000000000000000000, // NODE 30
        0b01000000000000000000000000000000  // NODE 31  
    };
#else
    uint32_t *graph = (uint32_t *) 0x02000010;
    graph[0]=0b00000000000000000000010001000010; // NODE 0
    graph[1]=0b00000000000000000000100000000101; // NODE 1
    graph[2]=0b00000000000000000000000000111010; // NODE 2
    graph[3]=0b00000000000000000000000000000100; // NODE 3
    graph[4]=0b00000000000000000000000000000100; // NODE 4
    graph[5]=0b00000000000000000000000000000100; // NODE 5
    graph[6]=0b00000000000000000000001110000001; // NODE 6
    graph[7]=0b00000000000000000000000001000000; // NODE 7
    graph[8]=0b00000000000000000000000001000000; // NODE 8
    graph[9]=0b00000000000000000000000001000000; // NODE 9
    graph[10]=0b00000101000000000000000000000001; // NODE 10
    graph[11]=0b00000000000010000001000000000010; // NODE 11
    graph[12]=0b00000000000000000110100000000000; // NODE 12
    graph[13]=0b00000000000000000001000000000000; // NODE 13
    graph[14]=0b00000000000000011001000000000000; // NODE 14
    graph[15]=0b00000000000000000100000000000000; // NODE 15
    graph[16]=0b00000000000001100100000000000000; // NODE 16
    graph[17]=0b00000000000000010000000000000000; // NODE 17
    graph[18]=0b00000000001010010000000000000000; // NODE 18
    graph[19]=0b00000000000101000000100000000000; // NODE 19
    graph[20]=0b00000000000010000000000000000000; // NODE 20
    graph[21]=0b00000000110001000000000000000000; // NODE 21
    graph[22]=0b00000000001000000000000000000000; // NODE 22
    graph[23]=0b01000001001000000000000000000000; // NODE 23
    graph[24]=0b00000010100000000000010000000000; // NODE 24
    graph[25]=0b00000001000000000000000000000000; // NODE 25
    graph[26]=0b00011000000000000000010000000000; // NODE 26
    graph[27]=0b00000100000000000000000000000000; // NODE 27
    graph[28]=0b01100100000000000000000000000000; // NODE 28 
    graph[29]=0b00010000000000000000000000000000; // NODE 29
    graph[30]=0b10010000100000000000000000000000; // NODE 30
    graph[31]=0b01000000000000000000000000000000; // NODE 31
#endif

#ifdef __linux__
    uint8_t path_planned[32];
#else
    uint8_t *path_planned = (uint8_t *)0x020000d0;
#endif

    uint8_t idx = 0;
    idx = flood_fill(START_POINT, END_POINT, graph, path_planned, idx);

    // Save the length of the planned path.
#ifdef __linux__
    uint8_t path_length = idx;
    _put_str("Path length: ");
    _put_value(path_length);
#else
    // For the target hardware, assume a memory-mapped register at address 0x020000e0 for path length.
    #define PATH_LENGTH_REG (* (volatile uint8_t *)0x020000e0)
    PATH_LENGTH_REG = idx;
#endif

    // Update NODE_POINT sequentially along the planned path.
    for (int i = 0; i < idx; ++i) {
        NODE_POINT = path_planned[i];
    }

#ifdef __linux__
    _put_str("######### Planned Path #########\n");
    for (int i = 0; i < idx; ++i) {
        _put_value(path_planned[i]);
    }
    _put_str("################################\n");
#else
    CPU_DONE = 1;
#endif

    return 0;
}
