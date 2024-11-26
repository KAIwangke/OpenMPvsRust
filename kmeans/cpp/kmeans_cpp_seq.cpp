#include <iostream>
#include <fstream>
#include <vector>
#include <cmath>
#include <limits>
#include <chrono>

using namespace std;

// Macro to calculate 2D index in a flattened 1D array
inline int calcIndex(int row, int col, int cols) {
    return row * cols + col;
}

long totalPoints;
int clustersCount;
vector<float> dataSet;
vector<float> centroids;
vector<int> pointClusterMap;
vector<int> clusterSizes;
int iterationCounter;

// Function to read input data from a file
void parseInputData(const string& filePath) {
    ifstream input(filePath);
    if (!input.is_open()) {
        cerr << "Error: Cannot open input file: " << filePath << endl;
        exit(EXIT_FAILURE);
    }

    input >> totalPoints;
    dataSet.resize(totalPoints * 2);
    for (long i = 0; i < totalPoints; ++i) {
        input >> dataSet[calcIndex(i, 0, 2)] >> dataSet[calcIndex(i, 1, 2)];
    }
    input.close();
}

// Function to initialize cluster centers
void initializeCentroids() {
    centroids.resize(clustersCount * 2);
    for (int i = 0; i < clustersCount; ++i) {
        centroids[calcIndex(i, 0, 2)] = dataSet[calcIndex(i, 0, 2)];
        centroids[calcIndex(i, 1, 2)] = dataSet[calcIndex(i, 1, 2)];
    }
}

// Function to assign points to the nearest cluster
bool updateClusterAssignments() {
    clusterSizes.assign(clustersCount, 0);
    bool assignmentsChanged = false;

    for (long i = 0; i < totalPoints; ++i) {
        float closestDistance = numeric_limits<float>::max();
        int bestCluster = -1;

        for (int j = 0; j < clustersCount; ++j) {
            float dx = centroids[calcIndex(j, 0, 2)] - dataSet[calcIndex(i, 0, 2)];
            float dy = centroids[calcIndex(j, 1, 2)] - dataSet[calcIndex(i, 1, 2)];
            float distance = dx * dx + dy * dy;

            if (distance < closestDistance) {
                closestDistance = distance;
                bestCluster = j;
            }
        }

        if (pointClusterMap[i] != bestCluster) {
            pointClusterMap[i] = bestCluster;
            assignmentsChanged = true;
        }
        clusterSizes[bestCluster]++;
    }
    return assignmentsChanged;
}

// Function to recalculate centroids
void recalculateCentroids() {
    vector<float> newCentroids(clustersCount * 2, 0.0);

    for (long i = 0; i < totalPoints; ++i) {
        int clusterID = pointClusterMap[i];
        newCentroids[calcIndex(clusterID, 0, 2)] += dataSet[calcIndex(i, 0, 2)];
        newCentroids[calcIndex(clusterID, 1, 2)] += dataSet[calcIndex(i, 1, 2)];
    }

    for (int j = 0; j < clustersCount; ++j) {
        if (clusterSizes[j] > 0) {
            centroids[calcIndex(j, 0, 2)] = newCentroids[calcIndex(j, 0, 2)] / clusterSizes[j];
            centroids[calcIndex(j, 1, 2)] = newCentroids[calcIndex(j, 1, 2)] / clusterSizes[j];
        }
    }
}

// Function to save results to a file
void exportResults(const string& filePath) {
    ofstream output(filePath);
    if (!output.is_open()) {
        cerr << "Error: Cannot open output file: " << filePath << endl;
        exit(EXIT_FAILURE);
    }

    output << "Total Iterations: " << iterationCounter << "\n";
    output << "Number of Points: " << totalPoints << "\n";
    output << "Centroids:\n";
    for (int i = 0; i < clustersCount; ++i) {
        output << centroids[calcIndex(i, 0, 2)] << ", " << centroids[calcIndex(i, 1, 2)] << "\n";
    }
    output << "Point Assignments:\n";
    for (long i = 0; i < totalPoints; ++i) {
        output << pointClusterMap[i] << " ";
    }
    output.close();
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        cerr << "Usage: " << argv[0] << " <input_file> <output_file> [clusters_count]" << endl;
        return EXIT_FAILURE;
    }

    string inputFilePath = argv[1];
    string outputFilePath = argv[2];
    clustersCount = (argc > 3) ? stoi(argv[3]) : 3;

    parseInputData(inputFilePath);
    initializeCentroids();
    pointClusterMap.assign(totalPoints, -1);

    auto startTime = chrono::high_resolution_clock::now();

    bool clustersChanged = true;
    iterationCounter = 0;

    while (clustersChanged) {
        clustersChanged = updateClusterAssignments();
        recalculateCentroids();
        iterationCounter++;
    }

    auto endTime = chrono::high_resolution_clock::now();
    auto duration = chrono::duration_cast<chrono::microseconds>(endTime - startTime).count();

    exportResults(outputFilePath);
    std::cout <<duration<< std::endl;

    return 0;
}

/* 
scp /Users/lidanwen/Desktop/multicore/project/kmeans/kmeans_cpp_seq.cpp dl5179@access.cims.nyu.edu:~/multicore/project/kmeans
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/kmeans
gcc -o kmeans_cpp_seq kmeans_cpp_seq.cpp -lstdc++ -lm -std=c++11 -fopenmp
./kmeans_cpp_seq input_1000.txt out1000_cpp_seq.txt 10
./kmeans_cpp_seq input_10000.txt out10000_cpp_seq.txt 10
./kmeans_cpp_seq input_100000.txt out100000_cpp_seq.txt 10
./kmeans_cpp_seq input_1000000.txt out1000000_cpp_seq.txt 10

cat out1000_cpp_seq.txt
time ./kmeans_cpp_seq input_1000.txt out1000_cpp_seq.txt
*/