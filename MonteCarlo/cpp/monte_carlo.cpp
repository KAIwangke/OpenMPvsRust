#include <iostream>
#include <random>
#include <omp.h>
#include <cmath>

double estimate_pi(long num_points) {
    long points_inside = 0;
    
    #pragma omp parallel
    {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<double> dis(0.0, 1.0);
        
        #pragma omp for reduction(+:points_inside)
        for (long i = 0; i < num_points; i++) {
            double x = dis(gen);
            double y = dis(gen);
            
            if (x*x + y*y <= 1.0) {
                points_inside++;
            }
        }
    }
    
    return 4.0 * points_inside / num_points;
}

int main(int argc, char* argv[]) {
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <num_points>" << std::endl;
        return 1;
    }
    
    const long num_points = std::stol(argv[1]);
    
    double start_time = omp_get_wtime();
    double pi_estimate = estimate_pi(num_points);
    double end_time = omp_get_wtime();
    
    std::cout << "Estimated π: " << pi_estimate << std::endl;
    std::cout << "Actual π: " << M_PI << std::endl;
    std::cout << "Error: " << std::abs(pi_estimate - M_PI) << std::endl;
    std::cout << "Time taken: " << end_time - start_time << " seconds" << std::endl;
    
    return 0;
}