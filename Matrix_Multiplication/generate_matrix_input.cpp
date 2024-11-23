#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// Function to generate a random matrix and save to a file
void generate_matrix(const char *filename, int size) {
    // Open file for writing
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error: Could not open file %s for writing\n", filename);
        exit(1);
    }

    // Write the dimensions of the matrix to the file
    fprintf(file, "%d %d\n", size, size);

    // Seed the random number generator
    srand(time(NULL));

    // Generate and write matrix values
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            int value = rand() % 100 + 1; // Random number between 1 and 100
            fprintf(file, "%d ", value);
        }
        fprintf(file, "\n");
    }

    fclose(file);
    printf("Matrix saved to %s\n", filename);
}

int main() {
    int size;

    // Prompt user for matrix size
    printf("Enter matrix size: ");
    scanf("%d", &size);

    // Generate filenames for the matrices
    char filename1[50], filename2[50];
    sprintf(filename1, "matrix1_%d.txt", size);
    sprintf(filename2, "matrix2_%d.txt", size);

    // Generate the matrices and save to files
    generate_matrix(filename1, size);
    generate_matrix(filename2, size);

    printf("Matrices successfully generated:\n");
    printf("Matrix 1: %s\n", filename1);
    printf("Matrix 2: %s\n", filename2);

    return 0;
}


/* 
scp /Users/lidanwen/Desktop/multicore/project/Matrix_Multiplication/generate_matrix_input.cpp dl5179@access.cims.nyu.edu:~/multicore/project/matrixmultiply
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/matrixmultiply
g++ generate_matrix_input.cpp -o generate_matrix_input
./generate_matrix_input
*/