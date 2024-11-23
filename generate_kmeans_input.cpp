#include <iostream>
#include <fstream>
#include <random>
#include <string>

using namespace std;

// Function to generate random points and write to a file
void generate_kmeans_input(int n) {
    // Create the filename based on n
    string filename = "input_" + to_string(n) + ".txt";
    ofstream output_file(filename);

    if (!output_file.is_open()) {
        cerr << "Error: Unable to create file " << filename << endl;
        return;
    }

    // Write the number of points as the first line
    output_file << n << endl;

    // Random number generation setup
    random_device rd;
    mt19937 gen(rd());
    uniform_real_distribution<float> dist(-1000.0, 1000.0); // Points between -1000 and 1000

    // Generate n random points
    for (int i = 0; i < n; ++i) {
        float x = dist(gen);
        float y = dist(gen);
        output_file << x << " " << y << endl;
    }

    // Close the file
    output_file.close();
    cout << "Generated " << n << " points and saved to " << filename << endl;
}

int main() {
    int n;
    cout << "Enter the number of points N: ";
    cin >> n;

    if (n <= 0) {
        cerr << "Error: The number of points must be greater than 0." << endl;
        return 1;
    }

    // Generate input file for K-Means
    generate_kmeans_input(n);

    return 0;
}

/* 
scp /Users/lidanwen/Desktop/multicore/project/kmeans/generate_kmeans_input.cpp dl5179@access.cims.nyu.edu:~/multicore/project/kmeans
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/kmeans
g++ generate_kmeans_input.cpp -o generate_kmeans_input
./generate_kmeans_input
*/