original data:




root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cd ..
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra# cd cpp
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ls
dijkstra_par.cpp  dijkstra_rt.cpp  dijkstra_seq.cpp  dijkstra_timing
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 10 4
Total Execution Time: 387 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 20.000
2. Thread Termination Overhead: 18.000
3. Parallel Region Overhead: 164.000
4. Critical Section Time: 0.000
5. Barrier Synchronization Time: 37.000
6. Reduction Operation Time: 17.000
7. Task Scheduling Overhead: 0.000
8. Memory Allocation Time: 0.000
9. Data Distribution Time: 48.000
10. Load Balancing Time: 162.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 100 4
Total Execution Time: 3252 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 14.000
2. Thread Termination Overhead: 12.000
3. Parallel Region Overhead: 1516.000
4. Critical Section Time: 11.000
5. Barrier Synchronization Time: 222.000
6. Reduction Operation Time: 14.000
7. Task Scheduling Overhead: 4.000
8. Memory Allocation Time: 0.000
9. Data Distribution Time: 12.000
10. Load Balancing Time: 1636.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 1000 4
Total Execution Time: 45887 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 17.000
2. Thread Termination Overhead: 12.000
3. Parallel Region Overhead: 15878.000
4. Critical Section Time: 0.000
5. Barrier Synchronization Time: 24.000
6. Reduction Operation Time: 14.000
7. Task Scheduling Overhead: 253.000
8. Memory Allocation Time: 2.000
9. Data Distribution Time: 13.000
10. Load Balancing Time: 28876.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 10000 4
Total Execution Time: 2.06916e+06 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 13.000
2. Thread Termination Overhead: 17.000
3. Parallel Region Overhead: 408680.000
4. Critical Section Time: 60.000
5. Barrier Synchronization Time: 24.000
6. Reduction Operation Time: 17.000
7. Task Scheduling Overhead: 240706.000
8. Memory Allocation Time: 1.000
9. Data Distribution Time: 24.000
10. Load Balancing Time: 1649467.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 10000 8
Total Execution Time: 2.73821e+06 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 33.000
2. Thread Termination Overhead: 178.000
3. Parallel Region Overhead: 678231.000
4. Critical Section Time: 417.000
5. Barrier Synchronization Time: 176.000
6. Reduction Operation Time: 45.000
7. Task Scheduling Overhead: 271028.000
8. Memory Allocation Time: 2.000
9. Data Distribution Time: 44.000
10. Load Balancing Time: 2048826.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 10000 16
Total Execution Time: 3.15125e+06 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 116.000
2. Thread Termination Overhead: 95.000
3. Parallel Region Overhead: 945048.000
4. Critical Section Time: 463.000
5. Barrier Synchronization Time: 1089.000
6. Reduction Operation Time: 109.000
7. Task Scheduling Overhead: 204582.000
8. Memory Allocation Time: 5.000
9. Data Distribution Time: 71.000
10. Load Balancing Time: 2195227.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# ./dijkstra_timing 10000 32
Total Execution Time: 4.47163e+06 microseconds

Detailed OpenMP Timing Metrics (microseconds):
1. Thread Creation Overhead: 161.000
2. Thread Termination Overhead: 123.000
3. Parallel Region Overhead: 1619016.000
4. Critical Section Time: 700.000
5. Barrier Synchronization Time: 1977.000
6. Reduction Operation Time: 177.000
7. Task Scheduling Overhead: 124921.000
8. Memory Allocation Time: 9.000
9. Data Distribution Time: 133.000
10. Load Balancing Time: 2841586.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/cpp# cd ..
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra# cd rust/
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# ls
Cargo.lock  Cargo.toml  src  target
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 10 4
    Finished `release` profile [optimized] target(s) in 0.02s
     Running `target/release/dijkstra_dt 10 4`
Running parallel Dijkstra's algorithm with graph size 10x10 using 4 threads...
Total Execution Time: 102 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 663.000
2. Thread Termination Overhead: 371.000
3. Parallel Region Overhead: 32.000
4. Join Overhead: 2765.000
5. Barrier Synchronization Time: 2288.000
6. Reduction Operation Time: 18.000
7. Scheduling Overhead: 32.000
8. Memory Allocation Time: 0.000
9. Data Distribution Time: 27.000
10. Load Balancing Time: 32.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 100 4
    Finished `release` profile [optimized] target(s) in 0.02s
     Running `target/release/dijkstra_dt 100 4`
Running parallel Dijkstra's algorithm with graph size 100x100 using 4 threads...
Total Execution Time: 1383 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 626.000
2. Thread Termination Overhead: 388.000
3. Parallel Region Overhead: 546.000
4. Join Overhead: 27871.000
5. Barrier Synchronization Time: 2232.000
6. Reduction Operation Time: 67.000
7. Scheduling Overhead: 547.000
8. Memory Allocation Time: 1.000
9. Data Distribution Time: 28.000
10. Load Balancing Time: 693.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 1000 4
    Finished `release` profile [optimized] target(s) in 0.02s
     Running `target/release/dijkstra_dt 1000 4`
Running parallel Dijkstra's algorithm with graph size 1000x1000 using 4 threads...
Total Execution Time: 32644 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 574.000
2. Thread Termination Overhead: 353.000
3. Parallel Region Overhead: 10504.000
4. Join Overhead: 286561.000
5. Barrier Synchronization Time: 2454.000
6. Reduction Operation Time: 376.000
7. Scheduling Overhead: 10602.000
8. Memory Allocation Time: 3.000
9. Data Distribution Time: 92.000
10. Load Balancing Time: 20828.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 10000 4
    Finished `release` profile [optimized] target(s) in 0.02s
     Running `target/release/dijkstra_dt 10000 4`
Running parallel Dijkstra's algorithm with graph size 10000x10000 using 4 threads...
Total Execution Time: 1185601 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 625.000
2. Thread Termination Overhead: 356.000
3. Parallel Region Overhead: 236731.000
4. Join Overhead: 2796733.000
5. Barrier Synchronization Time: 2273.000
6. Reduction Operation Time: 3023.000
7. Scheduling Overhead: 237465.000
8. Memory Allocation Time: 855.000
9. Data Distribution Time: 1963.000
10. Load Balancing Time: 934409.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 10000 8
    Finished `release` profile [optimized] target(s) in 0.16s
     Running `target/release/dijkstra_dt 10000 8`
Running parallel Dijkstra's algorithm with graph size 10000x10000 using 8 threads...
Total Execution Time: 1202509 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 1248.000
2. Thread Termination Overhead: 646.000
3. Parallel Region Overhead: 244753.000
4. Join Overhead: 2855109.000
5. Barrier Synchronization Time: 2343.000
6. Reduction Operation Time: 4324.000
7. Scheduling Overhead: 245556.000
8. Memory Allocation Time: 13.000
9. Data Distribution Time: 78.000
10. Load Balancing Time: 945918.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 10000 16
    Finished `release` profile [optimized] target(s) in 0.02s
     Running `target/release/dijkstra_dt 10000 16`
Running parallel Dijkstra's algorithm with graph size 10000x10000 using 16 threads...
Total Execution Time: 1196596 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 1631.000
2. Thread Termination Overhead: 553.000
3. Parallel Region Overhead: 246430.000
4. Join Overhead: 2829002.000
5. Barrier Synchronization Time: 2262.000
6. Reduction Operation Time: 3079.000
7. Scheduling Overhead: 247137.000
8. Memory Allocation Time: 13.000
9. Data Distribution Time: 100.000
10. Load Balancing Time: 938464.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust# cargo run --release --bin dijkstra_dt -- 10000 32
    Finished `release` profile [optimized] target(s) in 0.11s
     Running `target/release/dijkstra_dt 10000 32`
Running parallel Dijkstra's algorithm with graph size 10000x10000 using 32 threads...
Total Execution Time: 1368823 microseconds

Detailed Rayon Timing Metrics (microseconds):
1. Thread Pool Creation Overhead: 3246.000
2. Thread Termination Overhead: 1043.000
3. Parallel Region Overhead: 280461.000
4. Join Overhead: 2803878.000
5. Barrier Synchronization Time: 2294.000
6. Reduction Operation Time: 3135.000
7. Scheduling Overhead: 281259.000
8. Memory Allocation Time: 13.000
9. Data Distribution Time: 113.000
10. Load Balancing Time: 1076269.000
root@server:~/Perf-Eval-in-OpenMP-and-Rust/Dijkstra/rust#







# Performance Analysis: OpenMP vs Rayon Implementation

## Sheet 1: Total Execution Time Comparison (4 threads)
| Problem Size | OpenMP (μs) | Rayon (μs) | Difference (μs) | Rayon Speedup |
|-------------|-------------|------------|-----------------|---------------|
| 10          | 387         | 102        | 285            | 3.79x        |
| 100         | 3,252       | 1,383      | 1,869          | 2.35x        |
| 1,000       | 45,887      | 32,644     | 13,243         | 1.41x        |
| 10,000      | 2,069,160   | 1,185,601  | 883,559        | 1.75x        |

## Sheet 2: Thread Scaling Analysis (Size 10000)
| Thread Count | OpenMP (μs) | Rayon (μs) | OpenMP Scaling Efficiency | Rayon Scaling Efficiency |
|-------------|-------------|------------|-------------------------|------------------------|
| 4           | 2,069,160   | 1,185,601  | 100%                    | 100%                   |
| 8           | 2,738,210   | 1,202,509  | 75.6%                   | 98.6%                  |
| 16          | 3,151,250   | 1,196,596  | 65.7%                   | 99.1%                  |
| 32          | 4,471,630   | 1,368,823  | 46.3%                   | 86.6%                  |

## Sheet 3: Overhead Comparison (Size 10000, 4 threads)
| Metric                      | OpenMP (μs) | Rayon (μs) | Difference (μs) | % of Total Time (OpenMP) | % of Total Time (Rayon) |
|----------------------------|-------------|------------|-----------------|------------------------|----------------------|
| Thread Creation            | 13          | 625        | -612           | 0.001%                | 0.053%               |
| Thread Termination         | 17          | 356        | -339           | 0.001%                | 0.030%               |
| Parallel Region           | 408,680     | 236,731    | 171,949        | 19.75%                | 19.97%               |
| Critical Section/Join     | 60          | 2,796,733  | -2,796,673     | 0.003%                | 235.89%              |
| Barrier Synchronization   | 24          | 2,273      | -2,249         | 0.001%                | 0.192%               |
| Reduction Operation       | 17          | 3,023      | -3,006         | 0.001%                | 0.255%               |
| Task/Scheduling Overhead  | 240,706     | 237,465    | 3,241          | 11.63%                | 20.03%               |
| Memory Allocation         | 1           | 855        | -854           | 0.000%                | 0.072%               |
| Data Distribution         | 24          | 1,963      | -1,939         | 0.001%                | 0.166%               |
| Load Balancing           | 1,649,467   | 934,409    | 715,058        | 79.72%                | 78.81%               |

## Sheet 4: Performance Scaling Ratios (vs Size 10)
| Problem Size | OpenMP Ratio | Rayon Ratio | Theoretical N² Ratio |
|-------------|--------------|-------------|---------------------|
| 10          | 1x          | 1x          | 1x                  |
| 100         | 8.40x       | 13.56x      | 100x                |
| 1,000       | 118.57x     | 320.04x     | 10,000x             |
| 10,000      | 5,347.96x   | 11,623.54x  | 1,000,000x          |

## Sheet 5: Thread Creation and Management Costs
| Thread Count | OpenMP Creation (μs) | Rayon Creation (μs) | OpenMP Termination (μs) | Rayon Termination (μs) |
|-------------|---------------------|--------------------|-----------------------|---------------------|
| 4           | 13                  | 625                | 17                    | 356                 |
| 8           | 33                  | 1,248              | 178                   | 646                 |
| 16          | 116                 | 1,631              | 95                    | 553                 |
| 32          | 161                 | 3,246              | 123                   | 1,043               |

## Sheet 6: Load Balancing Analysis (Size 10000)
| Thread Count | OpenMP Load Balance (μs) | Rayon Load Balance (μs) | OpenMP % of Total | Rayon % of Total |
|-------------|------------------------|----------------------|------------------|-----------------|
| 4           | 1,649,467              | 934,409              | 79.72%           | 78.81%          |
| 8           | 2,048,826              | 945,918              | 74.82%           | 78.66%          |
| 16          | 2,195,227              | 938,464              | 69.66%           | 78.43%          |
| 32          | 2,841,586              | 1,076,269            | 63.55%           | 78.63%          |

## Sheet 7: Synchronization Costs Analysis
| Metric (Size 10000, 4 threads) | OpenMP (μs) | Rayon (μs) | Ratio (Rayon/OpenMP) |
|------------------------------|-------------|------------|-------------------|
| Barrier Synchronization      | 24          | 2,273      | 94.71x            |
| Critical Section/Join        | 60          | 2,796,733  | 46,612.22x        |
| Reduction Operation          | 17          | 3,023      | 177.82x           |
| Total Sync Cost             | 101         | 2,802,029  | 27,742.86x        |

