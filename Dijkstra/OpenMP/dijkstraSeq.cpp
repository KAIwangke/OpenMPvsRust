#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdbool.h>

// g++ -o dijkstraSeq dijkstraSeq.cpp

// print results
void printSolution(int * result, int size)
{
    printf("Vertex \t\t Distance from Source\n");
    for (int i = 0; i < size; i++)
        printf("%d \t\t\t\t %d\n", i, result[i]);
}



// is parallel
int minDistance(int * dist, bool * visited, int size)
{
    // Initialize min value
    int min = INT_MAX;
    int min_index;

    for (int i = 0; i < size; i++){
        // debug
        if (visited[i] == false && dist[i] <= min){
            min = dist[i];
            min_index = i;
        }
    }

    return min_index;
}

// is parallel
void dijkstra(int* graph, int src, int size){

    int* distances = (int*)calloc(size, sizeof(int));
    bool *visited = (bool*)calloc(size, sizeof(bool));

    for (int i = 0; i < size; i++) {
        distances[i] = INT_MAX;
        visited[i] = false;
    }

    distances[src] = 0;

    for (int count = 0; count < size - 1; count++) {
        // Pick the minimum distance vertex from the set of
        // vertices not yet processed. u is always equal to
        // src in the first iteration.
        int u = minDistance(distances, visited, size);

        // Mark the picked vertex as processed
        visited[u] = true;

        // Update dist value of the adjacent vertices of the
        // picked vertex.
        for (int v = 0; v < size; v++)
            if (!visited[v] && graph[u*size + v]
                && distances[u] != INT_MAX
                && distances[u] + graph[u*size + v] < distances[v])
                distances[v] = distances[u] + graph[u*size + v];
    }

    // print the constructed distance array
    printSolution(distances, size);

}



// this part doesn't matter, just an input generator
void generateAdjMatrix(int* adjMatrix, int size){

    int temp;

    for(int i = 0; i < size; i++){
        for(int j = i; j < size; j++){
            if(i == j) {
                adjMatrix[i*size+j] = 0;
                continue;
            }
            temp = rand() % 10;
            adjMatrix[i*size + j] = temp;
            adjMatrix[j*size + i] = temp;
        }
    }

    // prints adjacency matrix to see see
    /*
    for(int i = 0; i < size; i++){
        for(int j = 0; j < size; j++){
            printf("%d ", adjMatrix[i*size + j]);
        }
        printf("\n");
    }
    */
}


// 
int main(int argc, char* argv[]){

    int size = atoi(argv[1]);

    // generate an adjacency matrix used to represent a weighted graph
    int* graph = (int*)calloc(size*size, sizeof(int));
    generateAdjMatrix(graph, size);

    // starting node
    int source = 0;

    // start clock here

    dijkstra(graph, source, size);

    return 0;
}