#include <iostream>
#include <random>
#include <omp.h>
#include <cmath>
#include <cstdlib>
#include <chrono>

double estimate_pi(long num_points) {
    long points_inside = 0;

    #pragma omp parallel
    {
        std::random_device rd;
        std::mt19937 gen(rd() ^ (omp_get_thread_num() << 16));
        std::uniform_real_distribution<double> dis(0.0, 1.0);

        #pragma omp for reduction(+:points_inside) schedule(static, 10000)
        for (long i = 0; i < num_points; i++) {
            double x = dis(gen);
            double y = dis(gen);

            if (x * x + y * y <= 1.0) {
                points_inside++;
            }
        }
    }

    return 4.0 * static_cast<double>(points_inside) / static_cast<double>(num_points);
}

int main(int argc, char* argv[]) {
    if (argc < 2 || argc > 3) {
        std::cerr << "Usage: " << argv[0] << " <num_points> [num_threads]" << std::endl;
        return EXIT_FAILURE;
    }

    long num_points = std::stol(argv[1]);
    if (num_points <= 0) {
        std::cerr << "Number of points must be positive." << std::endl;
        return EXIT_FAILURE;
    }

    int num_threads = (argc == 3) ? std::stoi(argv[2]) : omp_get_max_threads();
    if (num_threads <= 0) {
        std::cerr << "Number of threads must be positive." << std::endl;
        return EXIT_FAILURE;
    }

    omp_set_num_threads(num_threads);

    auto start = std::chrono::high_resolution_clock::now();
    double pi_estimate = estimate_pi(num_points);
    auto end = std::chrono::high_resolution_clock::now();

    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
    std::cout << duration.count()<< std::endl;

    return EXIT_SUCCESS;
}