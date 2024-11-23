#include <iostream>
#include <vector>
#include <fstream>
#include <omp.h>
#include <chrono>

using namespace std;

// Function to read a matrix from a file
vector<vector<int>> read_matrix(const string &filename) {
    ifstream input_file(filename);
    if (!input_file.is_open()) {
        cerr << "Error: Unable to open file " << filename << endl;
        exit(1);
    }

    int rows, cols;
    input_file >> rows >> cols;

    vector<vector<int>> matrix(rows, vector<int>(cols));
    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            input_file >> matrix[i][j];
        }
    }

    input_file.close();
    return matrix;
}

// Function to write a matrix to a file
void write_matrix(const vector<vector<int>> &matrix, const string &filename) {
    ofstream output_file(filename);
    if (!output_file.is_open()) {
        cerr << "Error: Unable to open file " << filename << endl;
        exit(1);
    }

    int rows = matrix.size();
    int cols = matrix[0].size();
    output_file << rows << " " << cols << endl;

    for (const auto &row : matrix) {
        for (const auto &val : row) {
            output_file << val << " ";
        }
        output_file << endl;
    }

    output_file.close();
}

// Parallel Matrix Multiplication using OpenMP
vector<vector<int>> matrix_multiply_parallel(const vector<vector<int>> &A, const vector<vector<int>> &B, int thread_count) {
    int rows = A.size();
    int cols = B[0].size();
    int common_dim = A[0].size();

    vector<vector<int>> C(rows, vector<int>(cols, 0));

    // Parallelize the outer loop
    #pragma omp parallel for num_threads(thread_count) collapse(2)
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            for (int k = 0; k < common_dim; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    return C;
}

int main(int argc, char *argv[]) {
    if (argc < 4 || argc > 5) {
        cerr << "Usage: ./matrix_multiply_omp <matrix1_file> <matrix2_file> <output_file> [thread_count]" << endl;
        return 1;
    }

    string matrix1_file = argv[1];
    string matrix2_file = argv[2];
    string output_file = argv[3];
    int thread_count = (argc == 5) ? stoi(argv[4]) : 1; // Default thread count = 1

    // Read input matrices
    vector<vector<int>> A = read_matrix(matrix1_file);
    vector<vector<int>> B = read_matrix(matrix2_file);

    // Check if multiplication is valid
    if (A[0].size() != B.size()) {
        cerr << "Error: Matrix dimensions do not allow multiplication." << endl;
        return 1;
    }

    // Get matrix size (assuming square matrices for output purposes)
    int matrix_order = A.size();

    // Record start time
    auto start = chrono::high_resolution_clock::now();

    // Perform matrix multiplication using OpenMP
    vector<vector<int>> C = matrix_multiply_parallel(A, B, thread_count);

    // Record end time
    auto end = chrono::high_resolution_clock::now();

    // Calculate elapsed time in microseconds
    auto elapsed = chrono::duration_cast<chrono::microseconds>(end - start);

    // Write result to output file
    write_matrix(C, output_file);

    // Print output information
    cout << "The number of threads available = " << thread_count << endl;
    cout << "The matrix order N = " << matrix_order << endl;
    cout << "Elapsed microseconds = " << elapsed.count() << endl;

    return 0;
}



/* 
scp /Users/lidanwen/Desktop/multicore/project/Matrix_Multiplication/MatrixMultiply_omp_par.cpp dl5179@access.cims.nyu.edu:~/multicore/project/matrixmultiply
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
ssh dl5179@crunchy6.cims.nyu.edu	
6AFwk?J*ZGSx#m
cd ~/multicore/project/matrixmultiply
gcc -o MatrixMultiply_omp_par MatrixMultiply_omp_par.cpp -lstdc++ -std=c++11
./MatrixMultiply_omp_par matrix1_250.txt matrix2_250.txt output250_omp_par.txt
./MatrixMultiply_omp_par matrix1_500.txt matrix2_500.txt output500_omp_par.txt
./MatrixMultiply_omp_par matrix1_1000.txt matrix2_1000.txt output1000_omp_par.txt
./MatrixMultiply_omp_par matrix1_2000.txt matrix2_2000.txt output2000_omp_par.txt
*/