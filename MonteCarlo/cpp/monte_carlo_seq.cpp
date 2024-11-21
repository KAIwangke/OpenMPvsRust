#include <chrono>
#include <iostream>
#include <random>
#include <cmath>
using namespace std;
using namespace std::chrono;

double estimate_pi(long num_points) {
    long points_inside = 0;
    {
        std::random_device rd;
        std::mt19937 gen(rd());
        std::uniform_real_distribution<double> dis(0.0, 1.0);
        
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
    
    auto start = std::chrono::high_resolution_clock::now();
    double pi_estimate = estimate_pi(num_points);
    auto stop = std::chrono::high_resolution_clock::now();
    
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(stop - start);
    double seconds = duration.count() / 1000000.0;
    
    std::cout << "Estimated π: " << pi_estimate << std::endl;
    std::cout << "Actual π: " << M_PI << std::endl;
    std::cout << "Error: " << std::abs(pi_estimate - M_PI) << std::endl;
    std::cout << "Time taken: " << seconds << " seconds" << std::endl;
    
    return 0;
}