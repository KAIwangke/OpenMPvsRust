#include <iostream>
#include <fstream>
#include <vector>
#include <random>
#include <chrono>
#include <string>
#include <thread>
#include <mutex>

// Function to generate a random matrix and save to a file
void generate_matrix(const std::string& filename, int size, std::mt19937& rng, std::uniform_int_distribution<int>& dist, std::mutex& file_mutex) {
    // Open file for writing with buffering optimizations
    std::ofstream file(filename, std::ios::out | std::ios::trunc);
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file " << filename << " for writing\n";
        exit(EXIT_FAILURE);
    }

    // Write the dimensions of the matrix to the file
    file << size << " " << size << "\n";

    // Preallocate a buffer for each row to minimize dynamic memory allocations
    std::string row;
    row.reserve(size * 12); // Assuming each number takes up to 11 characters + space

    for (int i = 0; i < size; ++i) {
        row.clear();
        for (int j = 0; j < size; ++j) {
            row += std::to_string(dist(rng)) + " ";
        }
        row += "\n";
        file << row;
    }

    file.close();
    std::cout << "Matrix saved to " << filename << "\n";
}

// Function to generate matrices in parallel
void generate_matrices_parallel(int size, std::mutex& file_mutex) {
    // Generate filenames
    std::string filename1 = "matrix1_" + std::to_string(size) + ".txt";
    std::string filename2 = "matrix2_" + std::to_string(size) + ".txt";

    // Initialize random number generators
    std::random_device rd1, rd2;
    std::mt19937 rng1(rd1());
    std::mt19937 rng2(rd2());
    std::uniform_int_distribution<int> dist(1, 100); // Random numbers between 1 and 100

    // Launch threads to generate each matrix concurrently
    std::thread t1(generate_matrix, filename1, size, std::ref(rng1), std::ref(dist), std::ref(file_mutex));
    std::thread t2(generate_matrix, filename2, size, std::ref(rng2), std::ref(dist), std::ref(file_mutex));

    // Wait for both threads to finish
    t1.join();
    t2.join();

    std::cout << "Both matrices for size " << size << " have been generated.\n";
}

int main(int argc, char* argv[]) {
    // Check for command-line argument
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <matrix_size>\n";
        return EXIT_FAILURE;
    }

    int size = std::stoi(argv[1]);
    if (size <= 0) {
        std::cerr << "Error: Matrix size must be positive.\n";
        return EXIT_FAILURE;
    }

    // Mutex for thread-safe file operations (if needed in future extensions)
    std::mutex file_mutex;

    // Measure the time taken for matrix generation
    auto start_time = std::chrono::high_resolution_clock::now();

    // Generate both matrices in parallel
    generate_matrices_parallel(size, file_mutex);

    auto end_time = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = end_time - start_time;

    std::cout << "Total time taken: " << elapsed.count() << " seconds\n";

    return EXIT_SUCCESS;
}
