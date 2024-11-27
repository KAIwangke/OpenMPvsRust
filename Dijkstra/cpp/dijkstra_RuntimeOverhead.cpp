#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdbool.h>
#include <omp.h>
#include <chrono>
#include <iostream>
#include <vector>
#include <iomanip>
#include <thread>

struct TimingMetrics {
    double thread_creation_time;
    double thread_termination_time;
    double parallel_region_overhead;
    double critical_section_time;
    double barrier_sync_time;
    double reduction_operation_time;
    double scheduling_overhead;
    double memory_allocation_time;
    double data_distribution_time;
    double load_balancing_time;
    
    void print() {
        std::cout << std::fixed << std::setprecision(3)
                  << "\nDetailed OpenMP Timing Metrics (microseconds):\n"
                  << "1. Thread Creation Overhead: " << thread_creation_time << "\n"
                  << "2. Thread Termination Overhead: " << thread_termination_time << "\n"
                  << "3. Parallel Region Overhead: " << parallel_region_overhead << "\n"
                  << "4. Critical Section Time: " << critical_section_time << "\n"
                  << "5. Barrier Synchronization Time: " << barrier_sync_time << "\n"
                  << "6. Reduction Operation Time: " << reduction_operation_time << "\n"
                  << "7. Task Scheduling Overhead: " << scheduling_overhead << "\n"
                  << "8. Memory Allocation Time: " << memory_allocation_time << "\n"
                  << "9. Data Distribution Time: " << data_distribution_time << "\n"
                  << "10. Load Balancing Time: " << load_balancing_time << "\n";
    }
};

// Function to measure time difference in microseconds
double get_time_diff(std::chrono::high_resolution_clock::time_point start, 
                    std::chrono::high_resolution_clock::time_point end) {
    return std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
}

// Measure thread creation and termination overhead
void measure_thread_operations(TimingMetrics& metrics) {
    auto create_start = std::chrono::high_resolution_clock::now();
    auto term_start = create_start; // Initialize term_start here
    
    #pragma omp parallel
    {
        #pragma omp barrier
        #pragma omp single
        {
            auto create_end = std::chrono::high_resolution_clock::now();
            metrics.thread_creation_time = get_time_diff(create_start, create_end);
        }
        
        std::this_thread::sleep_for(std::chrono::microseconds(1));
        
        #pragma omp barrier
        #pragma omp single
        {
            term_start = std::chrono::high_resolution_clock::now();
        }
    }
    auto term_end = std::chrono::high_resolution_clock::now();
    metrics.thread_termination_time = get_time_diff(term_start, term_end);
}

// Measure barrier synchronization overhead
void measure_barrier_sync(TimingMetrics& metrics) {
    #pragma omp parallel
    {
        auto start = std::chrono::high_resolution_clock::now();
        #pragma omp barrier
        auto end = std::chrono::high_resolution_clock::now();
        
        #pragma omp critical
        {
            metrics.barrier_sync_time += get_time_diff(start, end);
        }
    }
}

// Measure reduction operation overhead
void measure_reduction(TimingMetrics& metrics, int size) {
    std::vector<int> data(size, 1);
    int sum = 0;
    
    auto start = std::chrono::high_resolution_clock::now();
    #pragma omp parallel for reduction(+:sum)
    for(int i = 0; i < size; i++) {
        sum += data[i];
    }
    auto end = std::chrono::high_resolution_clock::now();
    metrics.reduction_operation_time = get_time_diff(start, end);
}

int minDistance(int* dist, bool* visited, int size, TimingMetrics& metrics)
{
    int min = INT_MAX;
    int min_index = -1;
    
    auto start_parallel = std::chrono::high_resolution_clock::now();
    #pragma omp parallel
    {
        int local_min = INT_MAX;
        int local_min_index = -1;

        auto scheduling_start = std::chrono::high_resolution_clock::now();
        #pragma omp for nowait
        for (int i = 0; i < size; i++) {
            if (!visited[i] && dist[i] < local_min) {
                local_min = dist[i];
                local_min_index = i;
            }
        }
        auto scheduling_end = std::chrono::high_resolution_clock::now();
        
        #pragma omp atomic
        metrics.scheduling_overhead += get_time_diff(scheduling_start, scheduling_end);

        auto critical_start = std::chrono::high_resolution_clock::now();
        #pragma omp critical
        {
            if (local_min < min) {
                min = local_min;
                min_index = local_min_index;
            }
        }
        auto critical_end = std::chrono::high_resolution_clock::now();
        
        #pragma omp atomic
        metrics.critical_section_time += get_time_diff(critical_start, critical_end);
    }
    auto parallel_end = std::chrono::high_resolution_clock::now();
    metrics.parallel_region_overhead += get_time_diff(start_parallel, parallel_end);
    
    return min_index;
}

void dijkstra(int* graph, int src, int size, TimingMetrics& metrics) {
    auto alloc_start = std::chrono::high_resolution_clock::now();
    int* distances = (int*)malloc(size * sizeof(int));
    bool* visited = (bool*)malloc(size * sizeof(bool));
    auto alloc_end = std::chrono::high_resolution_clock::now();
    metrics.memory_allocation_time = get_time_diff(alloc_start, alloc_end);

    if (distances == NULL || visited == NULL) {
        std::cerr << "Memory allocation failed." << std::endl;
        exit(EXIT_FAILURE);
    }

    auto dist_start = std::chrono::high_resolution_clock::now();
    #pragma omp parallel for
    for (int i = 0; i < size; i++) {
        distances[i] = INT_MAX;
        visited[i] = false;
    }
    auto dist_end = std::chrono::high_resolution_clock::now();
    metrics.data_distribution_time = get_time_diff(dist_start, dist_end);

    distances[src] = 0;

    for (int count = 0; count < size - 1; count++) {
        int u = minDistance(distances, visited, size, metrics);
        
        if (u == -1 || distances[u] == INT_MAX)
            break;

        visited[u] = true;

        auto balance_start = std::chrono::high_resolution_clock::now();
        #pragma omp parallel for schedule(dynamic)
        for (int v = 0; v < size; v++) {
            if (!visited[v] && graph[u*size + v] && 
                distances[u] != INT_MAX && 
                distances[u] + graph[u*size + v] < distances[v]) {
                distances[v] = distances[u] + graph[u*size + v];
            }
        }
        auto balance_end = std::chrono::high_resolution_clock::now();
        metrics.load_balancing_time += get_time_diff(balance_start, balance_end);
    }

    free(distances);
    free(visited);
}

void generateAdjMatrix(int* adjMatrix, int size) {
    #pragma omp parallel for collapse(2)
    for(int i = 0; i < size; i++) {
        for(int j = 0; j < size; j++) {
            if(i == j) {
                adjMatrix[i*size + j] = 0;
            } else {
                adjMatrix[i*size + j] = rand() % 100 + 1;
            }
        }
    }
}

int main(int argc, char* argv[]) {
    if (argc < 2 || argc > 3) {
        std::cerr << "Usage: " << argv[0] << " <graph_size> [num_threads]" << std::endl;
        return EXIT_FAILURE;
    }

    int size = atoi(argv[1]);
    if (size <= 0) {
        std::cerr << "Error: Graph size must be a positive integer." << std::endl;
        return EXIT_FAILURE;
    }

    int num_threads;
    if (argc == 3) {
        num_threads = atoi(argv[2]);
        if (num_threads <= 0) {
            std::cerr << "Error: Number of threads must be a positive integer." << std::endl;
            return EXIT_FAILURE;
        }
        omp_set_num_threads(num_threads);
    } else {
        num_threads = omp_get_max_threads();
    }

    int* graph = (int*)calloc(size*size, sizeof(int));
    if (graph == NULL) {
        std::cerr << "Memory allocation for graph failed." << std::endl;
        return EXIT_FAILURE;
    }

    srand(time(NULL));
    generateAdjMatrix(graph, size);

    TimingMetrics metrics = {};
    
    measure_thread_operations(metrics);
    measure_barrier_sync(metrics);
    measure_reduction(metrics, size);
    
    auto start = std::chrono::high_resolution_clock::now();
    dijkstra(graph, 0, size, metrics);
    auto end = std::chrono::high_resolution_clock::now();
    
    double total_time = get_time_diff(start, end);
    
    std::cout << "Total Execution Time: " << total_time << " microseconds\n";
    metrics.print();

    free(graph);
    return EXIT_SUCCESS;
}