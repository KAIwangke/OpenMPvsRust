#include <iostream>
#include <vector>
#include <fstream>
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

// Function to perform matrix multiplication
vector<vector<int>> matrix_multiply(const vector<vector<int>> &A, const vector<vector<int>> &B) {
    int rows = A.size();
    int cols = B[0].size();
    int common_dim = A[0].size();

    vector<vector<int>> C(rows, vector<int>(cols, 0));

    for (int i = 0; i < rows; ++i) {
        for (int j = 0; j < cols; ++j) {
            for (int k = 0; k < common_dim; ++k) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }

    return C;
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        cerr << "Usage: ./matrix_multiply <matrix1_file> <matrix2_file> <output_file>" << endl;
        return 1;
    }

    string matrix1_file = argv[1];
    string matrix2_file = argv[2];
    string output_file = argv[3];

    // Read matrices from files
    vector<vector<int>> A = read_matrix(matrix1_file);
    vector<vector<int>> B = read_matrix(matrix2_file);

    // Check if multiplication is valid
    if (A[0].size() != B.size()) {
        cerr << "Error: Matrix dimensions do not allow multiplication." << endl;
        return 1;
    }

    // Record start time
    auto start = chrono::high_resolution_clock::now();

    // Perform matrix multiplication
    vector<vector<int>> C = matrix_multiply(A, B);

    // Record end time
    auto end = chrono::high_resolution_clock::now();

    // Calculate elapsed time in microseconds
    chrono::duration<double> elapsed = end - start;
    cout << "Matrix multiplication took " << elapsed.count() << " microseconds." << endl;

    // Write result to output file
    write_matrix(C, output_file);

    return 0;
}


/* 
scp /Users/lidanwen/Desktop/multicore/project/Matrix_Multiplication/MatrixMultiply_cpp_seq.cpp dl5179@access.cims.nyu.edu:~/multicore/project/matrixmultiply
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
ssh dl5179@crunchy6.cims.nyu.edu	
6AFwk?J*ZGSx#m
cd ~/multicore/project/matrixmultiply
gcc -o MatrixMultiply_cpp_seq MatrixMultiply_cpp_seq.cpp -lstdc++ -std=c++11
./MatrixMultiply_cpp_seq matrix1_3.txt matrix2_3.txt output3_cpp_seq.txt
*/