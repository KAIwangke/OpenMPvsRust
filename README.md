# Performance Evaluation: OpenMP vs Rust Parallel Implementations

This repository contains a comparative analysis of parallel programming implementations using OpenMP (C++) and Rust. The project evaluates the performance characteristics of different algorithms across various problem sizes and thread configurations.

## Algorithms Implemented

1. **Dijkstra's Algorithm**
   - Single-source shortest path computation
   - Implementations: Sequential and Parallel versions in both C++ and Rust

2. **Matrix Multiplication**
   - Standard matrix multiplication algorithm
   - Implementations: Sequential and Parallel versions in both C++ and Rust
   - Supports matrix sizes: 10x10, 100x100, 1000x1000, 2000x2000

3. **K-Means Clustering**
   - Clustering algorithm with customizable number of clusters
   - Implementations: Sequential and Parallel versions in both C++ and Rust
   - Default configuration: 10 clusters

4. **Monte Carlo Simulation**
   - Probabilistic simulation
   - Implementations: Sequential and Parallel versions in both C++ and Rust

## Project Structure

```
.
├── README.md
├── algorithms
│   ├── dijkstra
│   │   ├── cpp
│   │   │   ├── dijkstra_par.cpp
│   │   │   └── dijkstra_seq.cpp
│   │   └── rust
│   │       ├── Cargo.toml
│   │       └── src
│   │           └── bin
│   │               ├── dijkstra_par.rs
│   │               └── dijkstra_seq.rs
│   ├── kmeans
│   │   ├── cpp
│   │   │   ├── kmeans_par.cpp
│   │   │   └── kmeans_seq.cpp
│   │   └── rust
│   │       ├── Cargo.toml
│   │       └── src
│   │           └── bin
│   │               ├── kmeans_par.rs
│   │               └── kmeans_seq.rs
│   ├── matrix_multiplication
│   │   ├── cpp
│   │   │   ├── matrix_multiply_par.cpp
│   │   │   └── matrix_multiply_seq.cpp
│   │   └── rust
│   │       ├── Cargo.toml
│   │       └── src
│   │           └── bin
│   │               ├── matrix_multiply_par.rs
│   │               └── matrix_multiply_seq.rs
│   └── monte_carlo
│       ├── cpp
│       │   ├── monte_carlo_par.cpp
│       │   └── monte_carlo_seq.cpp
│       └── rust
│           ├── Cargo.toml
│           └── src
│               └── bin
│                   ├── monte_carlo_par.rs
│                   └── monte_carlo_seq.rs
├── clean.sh
├── run_all_multithread.sh
└── run_all.sh
```

## Prerequisites

- C++ Compiler with OpenMP support (GCC recommended)
- Rust (latest stable version)
- Cargo (Rust's package manager)
- Linux/Unix environment

## Building the Project

1. Clone the repository:
```bash
git clone [repository-url]
cd [repository-name]
```

2. Build all implementations:
```bash
./run_all_multithread.sh
```

This script will:
- Compile all C++ and Rust implementations
- Generate necessary input files
- Run experiments with different thread configurations
- Generate performance comparison results

## Running Experiments

The project includes two main scripts for running experiments:

1. `run_all_multithread.sh`: Runs all implementations with various thread configurations (2, 4, 8, 16, 32 threads)
2. `run_all.sh`: Runs sequential and single-threaded parallel implementations

### Configuration Options

- Problem sizes: 10, 100, 1000, 2000 (Matrix Multiplication)
- Thread configurations: 2, 4, 8, 16, 32
- K-means clusters: 10 (default)

## Results

Results are stored in the `results_[timestamp]` directory, containing:
- Individual timing results for each algorithm/implementation
- A comprehensive performance comparison report
- Execution logs and error reports

The performance comparison includes:
- Execution times for both sequential and parallel implementations
- Speedup calculations
- Cross-language performance comparisons

## Performance Metrics

The project measures:
1. Execution time (microseconds)
2. Speedup (Sequential time / Parallel time)
3. Scaling efficiency across different thread counts
4. Cross-language performance comparison