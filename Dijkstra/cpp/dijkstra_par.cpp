#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdbool.h>
#include <omp.h>
#include <chrono>
#include <iostream>
#include <vector>

// Compilation Instructions:
// g++ -O2 -fopenmp -std=c++11 -o dijkstraParallel dijkstraParallel.cpp

// Function to print the shortest distances from the source vertex
void printSolution(int* result, int size)
{
    printf("Vertex \t\t Distance from Source\n");
    for (int i = 0; i < size; i++)
        printf("%d \t\t\t\t %d\n", i, result[i]);
}

// Corrected parallel minDistance function
int minDistance(int* dist, bool* visited, int size)
{
    int min = INT_MAX;
    int min_index = -1;

    // Parallel region to find the minimum distance vertex
    #pragma omp parallel
    {
        int local_min = INT_MAX;
        int local_min_index = -1;

        #pragma omp for nowait
        for (int i = 0; i < size; i++) {
            if (!visited[i] && dist[i] < local_min) {
                local_min = dist[i];
                local_min_index = i;
            }
        }

        // Critical section to update the global minimum
        #pragma omp critical
        {
            if (local_min < min) {
                min = local_min;
                min_index = local_min_index;
            }
        }
    }

    return min_index;
}

// Parallel Dijkstra's algorithm
void dijkstra(int* graph, int src, int size){
    // Allocate memory for distances and visited arrays
    int* distances = (int*)malloc(size * sizeof(int));
    bool* visited = (bool*)malloc(size * sizeof(bool));

    if (distances == NULL || visited == NULL) {
        std::cerr << "Memory allocation failed." << std::endl;
        exit(EXIT_FAILURE);
    }

    // Initialize distances and visited arrays in parallel
    #pragma omp parallel for
    for (int i = 0; i < size; i++) {
        distances[i] = INT_MAX;
        visited[i] = false;
    }

    distances[src] = 0;

    for (int count = 0; count < size - 1; count++) {
        // Pick the minimum distance vertex from the set of vertices not yet processed
        int u = minDistance(distances, visited, size);

        // If the smallest distance is INT_MAX, remaining vertices are inaccessible
        if (u == -1 || distances[u] == INT_MAX)
            break;

        // Mark the picked vertex as processed
        visited[u] = true;

        // Update distances of adjacent vertices in parallel
        #pragma omp parallel for
        for (int v = 0; v < size; v++) {
            if (!visited[v] && graph[u*size + v] && 
                distances[u] != INT_MAX && 
                distances[u] + graph[u*size + v] < distances[v]) {
                distances[v] = distances[u] + graph[u*size + v];
            }
        }
    }

    // Uncomment the following line to print the shortest distances
    // printSolution(distances, size);

    // Free allocated memory
    free(distances);
    free(visited);
}

// Function to generate a random adjacency matrix for an undirected graph
void generateAdjMatrix(int* adjMatrix, int size){
    int temp;

    // Seed the random number generator
    srand(time(NULL));

    #pragma omp parallel for private(temp)
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

    // Optional: Print the adjacency matrix
    /*
    for(int i = 0; i < size; i++){
        for(int j = 0; j < size; j++){
            // printf("%d ", adjMatrix[i*size + j]);
        }
        printf("\n");
    }
    */
}

int main(int argc, char* argv[]){

    if (argc < 2 || argc > 3) {
        std::cerr << "Usage: " << argv[0] << " <graph_size> [num_threads]" << std::endl;
        return EXIT_FAILURE;
    }

    int size = atoi(argv[1]);

    if (size <= 0) {
        std::cerr << "Error: Graph size must be a positive integer." << std::endl;
        return EXIT_FAILURE;
    }

    // Determine the number of threads
    int num_threads;
    if (argc == 3) {
        num_threads = atoi(argv[2]);
        if (num_threads <= 0) {
            std::cerr << "Error: Number of threads must be a positive integer." << std::endl;
            return EXIT_FAILURE;
        }
        omp_set_num_threads(num_threads);
    } else {
        // Default to maximum available threads
        num_threads = omp_get_max_threads();
    }

    // Allocate memory for the adjacency matrix
    int* graph = (int*)calloc(size*size, sizeof(int));
    if (graph == NULL) {
        std::cerr << "Memory allocation for graph failed." << std::endl;
        return EXIT_FAILURE;
    }

    // Generate the adjacency matrix
    generateAdjMatrix(graph, size);

    std::cout << "Running parallel Dijkstra's algorithm with graph size " 
              << size << "x" << size << " using " << num_threads << " thread(s)..." << std::endl;

    // Start timing
    auto start = std::chrono::high_resolution_clock::now();

    // Execute Dijkstra's algorithm
    dijkstra(graph, 0, size);

    // End timing
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::micro> duration = end - start;
    double seconds = duration.count() / 1000000.0;

    std::cout << "Execution Time: " << duration.count() << " microseconds" << std::endl;

    // Uncomment the following line to print the shortest distances
    // printSolution(distances, size);

    // Free allocated memory for the graph
    free(graph);

    return EXIT_SUCCESS;
}
