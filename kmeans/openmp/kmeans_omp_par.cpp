#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <cfloat>
#include <chrono>
#include <omp.h>

using namespace std;

// Macro to calculate the 1D index in a 2D array
#define IDX(i, j, N) ((i) * (N) + (j))

// Global variables
long N;                // Number of data points
float* points;         // Array to store 2D points
float* centroids;      // Array to store centroids
int* clusters;         // Array to store cluster assignment of each point
int* cluster_sizes;    // Array to store the size of each cluster
int iterations;        // Number of iterations
int K = 3;             // Default number of clusters
int num_threads = 1;   // Default number of threads

// Function to read input data from a file
int readInputFile(const string& filename) {
    ifstream input(filename);
    if (!input.is_open()) {
        cerr << "Error: Unable to open input file." << endl;
        return 1;
    }

    // Read the number of points
    input >> N;

    // Allocate memory for points
    points = new float[N * 2];
    for (long i = 0; i < N; ++i) {
        input >> points[IDX(i, 0, 2)] >> points[IDX(i, 1, 2)];
    }

    input.close();
    return 0;
}

// Function to initialize centroids with the first K points
void initializeCentroids() {
    centroids = new float[K * 2];
    for (int i = 0; i < K; ++i) {
        centroids[IDX(i, 0, 2)] = points[IDX(i, 0, 2)];
        centroids[IDX(i, 1, 2)] = points[IDX(i, 1, 2)];
    }
}

// Function to assign points to the closest centroid
bool assignPointsToClusters() {
    // Reset cluster sizes
    cluster_sizes = new int[K]();
    bool hasChanged = false;

    // Parallelize the loop to assign points
    #pragma omp parallel for num_threads(num_threads) shared(points, centroids, clusters, cluster_sizes) reduction(||:hasChanged)
    for (long i = 0; i < N; ++i) {
        float min_distance = FLT_MAX;
        int closest_centroid = -1;

        // Find the closest centroid
        for (int j = 0; j < K; ++j) {
            float dx = centroids[IDX(j, 0, 2)] - points[IDX(i, 0, 2)];
            float dy = centroids[IDX(j, 1, 2)] - points[IDX(i, 1, 2)];
            float distance = dx * dx + dy * dy;

            if (distance < min_distance) {
                min_distance = distance;
                closest_centroid = j;
            }
        }

        // Check if the cluster assignment has changed
        if (clusters[i] != closest_centroid) {
            clusters[i] = closest_centroid;
            hasChanged = true;
        }

        // Increment the size of the cluster
        #pragma omp atomic
        cluster_sizes[closest_centroid]++;
    }
    return hasChanged;
}

// Function to update centroids based on assigned points
void updateCentroids() {
    vector<float> new_centroids(K * 2, 0.0);

    // Accumulate the points in each cluster
    #pragma omp parallel for
    for (long i = 0; i < N; ++i) {
        int cluster_id = clusters[i];
        #pragma omp atomic
        new_centroids[IDX(cluster_id, 0, 2)] += points[IDX(i, 0, 2)];
        #pragma omp atomic
        new_centroids[IDX(cluster_id, 1, 2)] += points[IDX(i, 1, 2)];
    }

    // Compute the new centroids
    #pragma omp parallel for
    for (int j = 0; j < K; ++j) {
        if (cluster_sizes[j] > 0) {
            centroids[IDX(j, 0, 2)] = new_centroids[IDX(j, 0, 2)] / cluster_sizes[j];
            centroids[IDX(j, 1, 2)] = new_centroids[IDX(j, 1, 2)] / cluster_sizes[j];
        }
    }
}

// Function to print the results to a file
void printResults(const string& filename) {
    ofstream output(filename);
    if (!output.is_open()) {
        cerr << "Error: Unable to open output file." << endl;
        return;
    }

    // Output the number of iterations and points
    output << "Total Iterations: " << iterations << "\n";
    output << "Number of Points: " << N << "\n";

    // Output the centroids
    output << "Centroids:\n";
    for (int i = 0; i < K; ++i) {
        output << centroids[IDX(i, 0, 2)] << ", " << centroids[IDX(i, 1, 2)] << "\n";
    }

    // Output the cluster assignments
    output << "Point Assignments:\n";
    for (long i = 0; i < N; ++i) {
        output << clusters[i];
        if (i < N - 1) output << " ";
    }
    output << "\n";

    output.close();
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        cerr << "Usage: " << argv[0] << " <input_file> <output_file> [num_clusters] [num_threads]" << endl;
        return 1;
    }

    string input_file = argv[1];
    string output_file = argv[2];

    // Read number of clusters and threads if provided
    if (argc > 3) K = stoi(argv[3]);
    if (argc > 4) num_threads = stoi(argv[4]);

    // Read input data
    if (readInputFile(input_file)) return 1;

    // Initialize centroids and clusters
    initializeCentroids();
    clusters = new int[N]();
    iterations = 0;

    // Measure execution time
    auto start_time = chrono::high_resolution_clock::now();

    // Perform K-Means clustering
    bool hasChanged = true;
    while (hasChanged) {
        hasChanged = assignPointsToClusters();
        updateCentroids();
        iterations++;
    }

    auto end_time = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::microseconds>(end_time - start_time).count();

    // Output results
    printResults(output_file);

    // Print execution details
    cout << "Parallel K-Means completed in " << duration << " microseconds." << endl;
    cout << "Number of clusters: " << K << ", Number of threads: " << num_threads << endl;

    // Clean up memory
    delete[] points;
    delete[] centroids;
    delete[] clusters;
    delete[] cluster_sizes;

    return 0;
}


/* 
scp /Users/lidanwen/Desktop/multicore/project/kmeans/kmeans_omp_par.cpp dl5179@access.cims.nyu.edu:~/multicore/project/kmeans
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
ssh dl5179@crunchy6.cims.nyu.edu	
6AFwk?J*ZGSx#m
cd ~/multicore/project/kmeans
gcc -o kmeans_omp_par kmeans_omp_par.cpp -lstdc++ -lm -std=c++11 -fopenmp
./kmeans_omp_par input_1000.txt out1000_omp_par 10
./kmeans_omp_par input_10000.txt out10000_omp_par 10
./kmeans_omp_par input_100000.txt out100000_omp_par 10
./kmeans_omp_par input_1000000.txt out1000000_omp_par 10
time ./kmeans_omp_par input_1000.txt out1000_omp_par 10
*/