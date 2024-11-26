# Performance Analysis: OpenMP vs Rayon Implementation

original data

```jsx

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

```

## Sheet 1: Total Execution Time Comparison (4 threads)

| Problem Size | OpenMP (ms) | Rayon (ms) | Difference (ms) | Rayon Speedup |
| --- | --- | --- | --- | --- |
| 10 | 387 | 102 | 285 | 3.79x |
| 100 | 3,252 | 1,383 | 1,869 | 2.35x |
| 1,000 | 45,887 | 32,644 | 13,243 | 1.41x |
| 10,000 | 2,069,160 | 1,185,601 | 883,559 | 1.75x |

## Sheet 2: Thread Scaling Analysis (Size 10000)

| Thread Count | OpenMP (ms) | Rayon (ms) | OpenMP Scaling Efficiency | Rayon Scaling Efficiency |
| --- | --- | --- | --- | --- |
| 4 | 2,069,160 | 1,185,601 | 100% | 100% |
| 8 | 2,738,210 | 1,202,509 | 75.6% | 98.6% |
| 16 | 3,151,250 | 1,196,596 | 65.7% | 99.1% |
| 32 | 4,471,630 | 1,368,823 | 46.3% | 86.6% |

## Sheet 3: Overhead Comparison (Size 10000, 4 threads)

| Metric | OpenMP (ms) | Rayon (ms) | Difference (ms) | % of Total Time (OpenMP) | % of Total Time (Rayon) |
| --- | --- | --- | --- | --- | --- |
| Thread Creation | 13 | 625 | -612 | 0.001% | 0.053% |
| Thread Termination | 17 | 356 | -339 | 0.001% | 0.030% |
| Parallel Region | 408,680 | 236,731 | 171,949 | 19.75% | 19.97% |
| Critical Section/Join | 60 | 2,796,733 | -2,796,673 | 0.003% | 235.89% |
| Barrier Synchronization | 24 | 2,273 | -2,249 | 0.001% | 0.192% |
| Reduction Operation | 17 | 3,023 | -3,006 | 0.001% | 0.255% |
| Task/Scheduling Overhead | 240,706 | 237,465 | 3,241 | 11.63% | 20.03% |
| Memory Allocation | 1 | 855 | -854 | 0.000% | 0.072% |
| Data Distribution | 24 | 1,963 | -1,939 | 0.001% | 0.166% |
| Load Balancing | 1,649,467 | 934,409 | 715,058 | 79.72% | 78.81% |

## Sheet 4: Performance Scaling Ratios (vs Size 10)

| Problem Size | OpenMP Ratio | Rayon Ratio | Theoretical N² Ratio |
| --- | --- | --- | --- |
| 10 | 1x | 1x | 1x |
| 100 | 8.40x | 13.56x | 100x |
| 1,000 | 118.57x | 320.04x | 10,000x |
| 10,000 | 5,347.96x | 11,623.54x | 1,000,000x |

## Sheet 5: Thread Creation and Management Costs

| Thread Count | OpenMP Creation (ms) | Rayon Creation (ms) | OpenMP Termination (ms) | Rayon Termination (ms) |
| --- | --- | --- | --- | --- |
| 4 | 13 | 625 | 17 | 356 |
| 8 | 33 | 1,248 | 178 | 646 |
| 16 | 116 | 1,631 | 95 | 553 |
| 32 | 161 | 3,246 | 123 | 1,043 |

## Sheet 6: Load Balancing Analysis (Size 10000)

| Thread Count | OpenMP Load Balance (ms) | Rayon Load Balance (ms) | OpenMP % of Total | Rayon % of Total |
| --- | --- | --- | --- | --- |
| 4 | 1,649,467 | 934,409 | 79.72% | 78.81% |
| 8 | 2,048,826 | 945,918 | 74.82% | 78.66% |
| 16 | 2,195,227 | 938,464 | 69.66% | 78.43% |
| 32 | 2,841,586 | 1,076,269 | 63.55% | 78.63% |

## Sheet 7: Synchronization Costs Analysis

| Metric (Size 10000, 4 threads) | OpenMP (ms) | Rayon (ms) | Ratio (Rayon/OpenMP) |
| --- | --- | --- | --- |
| Barrier Synchronization | 24 | 2,273 | 94.71x |
| Critical Section/Join | 60 | 2,796,733 | 46,612.22x |
| Reduction Operation | 17 | 3,023 | 177.82x |
| Total Sync Cost | 101 | 2,802,029 | 27,742.86x |

# Performance Comparison: Rust vs C++ with Multiple Thread Configurations

1. Dijkstra's Algorithm

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.144 | 148.738 | 1.000 | 395.000 | 0.00 | 0.00 |
| 4 | 0.144 | 158.112 | 1.000 | 390.000 | 0.00 | 0.00 |
| 8 | 0.144 | 132.799 | 1.000 | 287.000 | 0.00 | 0.00 |
| 16 | 0.144 | 238.491 | 1.000 | 759.000 | 0.00 | 0.00 |
| 32 | 0.144 | 2073.560 | 1.000 | 2995.000 | 0.00 | 0.00 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.105 | 904.326 | 75.000 | 5545.000 | 0.00 | 0.01 |
| 4 | 0.105 | 1032.070 | 75.000 | 4763.000 | 0.00 | 0.02 |
| 8 | 0.105 | 1307.030 | 75.000 | 4512.000 | 0.00 | 0.02 |
| 16 | 0.105 | 2417.800 | 75.000 | 6886.000 | 0.00 | 0.01 |
| 32 | 0.105 | 23535.200 | 75.000 | 14134.000 | 0.00 | 0.01 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.427 | 13326.200 | 17693.000 | 66801.000 | 0.00 | 0.26 |
| 4 | 0.427 | 17659.100 | 17693.000 | 98751.000 | 0.00 | 0.18 |
| 8 | 0.427 | 14014.500 | 17693.000 | 72895.000 | 0.00 | 0.24 |
| 16 | 0.427 | 26145.000 | 17693.000 | 202284.000 | 0.00 | 0.09 |
| 32 | 0.427 | 240863.000 | 17693.000 | 334495.000 | 0.00 | 0.05 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.151 | 223967.000 | 687002.000 | 1198560.000 | 0.00 | 0.57 |
| 4 | 0.151 | 445140.000 | 687002.000 | 1181648.000 | 0.00 | 0.58 |
| 8 | 0.151 | 257050.000 | 687002.000 | 1384717.000 | 0.00 | 0.50 |
| 16 | 0.151 | 193725.000 | 687002.000 | 2046872.000 | 0.00 | 0.34 |
| 32 | 0.151 | 224469.000 | 687002.000 | 3160273.000 | 0.00 | 0.22 |
1. Matrix Multiplication

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 6.000 | 1021.000 | 10.000 | 62.000 | 0.01 | 0.16 |
| 4 | 6.000 | 1244.000 | 10.000 | 90.000 | 0.00 | 0.11 |
| 8 | 6.000 | 1586.000 | 10.000 | 135.000 | 0.00 | 0.07 |
| 16 | 6.000 | 2378.000 | 10.000 | 207.000 | 0.00 | 0.05 |
| 32 | 6.000 | 4363.000 | 10.000 | 123.000 | 0.00 | 0.08 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 2533.000 | 2385.000 | 5755.000 | 2138.000 | 1.06 | 2.69 |
| 4 | 2533.000 | 1955.000 | 5755.000 | 1165.000 | 1.30 | 4.94 |
| 8 | 2533.000 | 1978.000 | 5755.000 | 738.000 | 1.28 | 7.80 |
| 16 | 2533.000 | 2577.000 | 5755.000 | 581.000 | 0.98 | 9.91 |
| 32 | 2533.000 | 4516.000 | 5755.000 | 1477.000 | 0.56 | 3.90 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 7165361.000 | 4044571.000 | 6907704.000 | 3972155.000 | 1.77 | 1.74 |
| 4 | 7165361.000 | 2189863.000 | 6907704.000 | 2428419.000 | 3.27 | 2.84 |
| 8 | 7165361.000 | 1384436.000 | 6907704.000 | 1328809.000 | 5.18 | 5.20 |
| 16 | 7165361.000 | 879525.000 | 6907704.000 | 685343.000 | 8.15 | 10.08 |
| 32 | 7165361.000 | 771939.000 | 6907704.000 | 713466.000 | 9.28 | 9.68 |
1. K-Means Clustering

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 3.000 | 6182.000 | 4.000 | 65.000 | 0.00 | 0.06 |
| 4 | 3.000 | 10787.000 | 4.000 | 99.000 | 0.00 | 0.04 |
| 8 | 3.000 | 2976.000 | 4.000 | 166.000 | 0.00 | 0.02 |
| 16 | 3.000 | 1649.000 | 4.000 | 331.000 | 0.00 | 0.01 |
| 32 | 3.000 | 5808.000 | 4.000 | 792.000 | 0.00 | 0.01 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 99.000 | 42328.000 | 86.000 | 490.000 | 0.00 | 0.18 |
| 4 | 99.000 | 20079.000 | 86.000 | 532.000 | 0.00 | 0.16 |
| 8 | 99.000 | 21505.000 | 86.000 | 1469.000 | 0.00 | 0.06 |
| 16 | 99.000 | 8858.000 | 86.000 | 1124.000 | 0.01 | 0.08 |
| 32 | 99.000 | 45487.000 | 86.000 | 6865.000 | 0.00 | 0.01 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 1277.000 | 51015.000 | 1326.000 | 1832.000 | 0.03 | 0.72 |
| 4 | 1277.000 | 35835.000 | 1326.000 | 4327.000 | 0.04 | 0.31 |
| 8 | 1277.000 | 39349.000 | 1326.000 | 6674.000 | 0.03 | 0.20 |
| 16 | 1277.000 | 16516.000 | 1326.000 | 5879.000 | 0.08 | 0.23 |
| 32 | 1277.000 | 111597.000 | 1326.000 | 25440.000 | 0.01 | 0.05 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 25770.000 | 198456.000 | 27661.000 | 124884.000 | 0.13 | 0.22 |
| 4 | 25770.000 | 151084.000 | 27661.000 | 116294.000 | 0.17 | 0.24 |
| 8 | 25770.000 | 172943.000 | 27661.000 | 114911.000 | 0.15 | 0.24 |
| 16 | 25770.000 | 96513.000 | 27661.000 | 120233.000 | 0.27 | 0.23 |
| 32 | 25770.000 | 218040.000 | 27661.000 | 132238.000 | 0.12 | 0.21 |
1. Monte Carlo

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 9.000 | 973.000 | 15.000 | 26.000 | 0.01 | 0.58 |
| 4 | 9.000 | 719.000 | 15.000 | 107.000 | 0.01 | 0.14 |
| 8 | 9.000 | 915.000 | 15.000 | 27.000 | 0.01 | 0.56 |
| 16 | 9.000 | 2304.000 | 15.000 | 30.000 | 0.00 | 0.50 |
| 32 | 9.000 | 2101.000 | 15.000 | 20.000 | 0.00 | 0.75 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 11.000 | 556.000 | 8.000 | 56.000 | 0.02 | 0.14 |
| 4 | 11.000 | 348.000 | 8.000 | 16.000 | 0.03 | 0.50 |
| 8 | 11.000 | 861.000 | 8.000 | 58.000 | 0.01 | 0.14 |
| 16 | 11.000 | 2900.000 | 8.000 | 67.000 | 0.00 | 0.12 |
| 32 | 11.000 | 1841.000 | 8.000 | 16.000 | 0.01 | 0.50 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 27.000 | 255.000 | 15.000 | 70.000 | 0.11 | 0.21 |
| 4 | 27.000 | 649.000 | 15.000 | 40.000 | 0.04 | 0.38 |
| 8 | 27.000 | 894.000 | 15.000 | 64.000 | 0.03 | 0.23 |
| 16 | 27.000 | 2212.000 | 15.000 | 46.000 | 0.01 | 0.33 |
| 32 | 27.000 | 2060.000 | 15.000 | 43.000 | 0.01 | 0.35 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 178.000 | 707.000 | 105.000 | 160.000 | 0.25 | 0.66 |
| 4 | 178.000 | 888.000 | 105.000 | 149.000 | 0.20 | 0.70 |
| 8 | 178.000 | 2122.000 | 105.000 | 136.000 | 0.08 | 0.77 |
| 16 | 178.000 | 2790.000 | 105.000 | 146.000 | 0.06 | 0.72 |
| 32 | 178.000 | 1796.000 | 105.000 | 130.000 | 0.10 | 0.81 |





updating the results

Date: Tue Nov 26 03:31:14 PM EST 2024

1. Dijkstra's Algorithm

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.192 | 71.451 | 2.000 | 327.000 | 0.00 | 0.01 |
| 4 | 0.192 | 90.652 | 2.000 | 455.000 | 0.00 | 0.00 |
| 8 | 0.192 | 178.203 | 2.000 | 593.000 | 0.00 | 0.00 |
| 16 | 0.192 | 443.835 | 2.000 | 834.000 | 0.00 | 0.00 |
| 32 | 0.192 | 1311.890 | 2.000 | 2040.000 | 0.00 | 0.00 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.177 | 688.787 | 117.000 | 5091.000 | 0.00 | 0.02 |
| 4 | 0.177 | 875.133 | 117.000 | 6521.000 | 0.00 | 0.02 |
| 8 | 0.177 | 1593.690 | 117.000 | 8475.000 | 0.00 | 0.01 |
| 16 | 0.177 | 3832.280 | 117.000 | 12771.000 | 0.00 | 0.01 |
| 32 | 0.177 | 11965.500 | 117.000 | 23129.000 | 0.00 | 0.01 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.200 | 9676.420 | 10632.000 | 54647.000 | 0.00 | 0.19 |
| 4 | 0.200 | 9655.760 | 10632.000 | 87719.000 | 0.00 | 0.12 |
| 8 | 0.200 | 15243.300 | 10632.000 | 119079.000 | 0.00 | 0.09 |
| 16 | 0.200 | 30524.100 | 10632.000 | 222599.000 | 0.00 | 0.05 |
| 32 | 0.200 | 107244.000 | 10632.000 | 456368.000 | 0.00 | 0.02 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 0.189 | 402272.000 | 1011609.000 | 3017103.000 | 0.00 | 0.34 |
| 4 | 0.189 | 263390.000 | 1011609.000 | 2640552.000 | 0.00 | 0.38 |
| 8 | 0.189 | 243499.000 | 1011609.000 | 2911736.000 | 0.00 | 0.35 |
| 16 | 0.189 | 381357.000 | 1011609.000 | 4677314.000 | 0.00 | 0.22 |
| 32 | 0.189 | 0.000 | 1011609.000 | 9732976.000 | 0.00 | 0.10 |
1. Matrix Multiplication

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 4.000 | 580.000 | 6.000 | 63.000 | 0.01 | 0.10 |
| 4 | 4.000 | 740.000 | 6.000 | 78.000 | 0.01 | 0.08 |
| 8 | 4.000 | 1054.000 | 6.000 | 138.000 | 0.00 | 0.04 |
| 16 | 4.000 | 1791.000 | 6.000 | 304.000 | 0.00 | 0.02 |
| 32 | 4.000 | 3083.000 | 6.000 | 374.000 | 0.00 | 0.02 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 2069.000 | 1663.000 | 4957.000 | 1913.000 | 1.24 | 2.59 |
| 4 | 2069.000 | 1379.000 | 4957.000 | 1049.000 | 1.50 | 4.73 |
| 8 | 2069.000 | 1408.000 | 4957.000 | 689.000 | 1.47 | 7.19 |
| 16 | 2069.000 | 1987.000 | 4957.000 | 656.000 | 1.04 | 7.56 |
| 32 | 2069.000 | 3279.000 | 4957.000 | 734.000 | 0.63 | 6.75 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 5488744.000 | 2812304.000 | 9901493.000 | 4084170.000 | 1.95 | 2.42 |
| 4 | 5488744.000 | 1442037.000 | 9901493.000 | 2013766.000 | 3.81 | 4.92 |
| 8 | 5488744.000 | 745862.000 | 9901493.000 | 1044649.000 | 7.36 | 9.48 |
| 16 | 5488744.000 | 385679.000 | 9901493.000 | 522628.000 | 14.23 | 18.95 |
| 32 | 5488744.000 | 430365.000 | 9901493.000 | 422728.000 | 12.75 | 23.42 |

Problem Size: 2000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 170174732.000 | 85665363.000 | 86829748.000 | 88723221.000 | 1.99 | 0.98 |
| 4 | 170174732.000 | 43728883.000 | 86829748.000 | 46129083.000 | 3.89 | 1.88 |
| 8 | 170174732.000 | 21848939.000 | 86829748.000 | 22876838.000 | 7.79 | 3.80 |
| 16 | 170174732.000 | 11013301.000 | 86829748.000 | 11637401.000 | 15.45 | 7.46 |
| 32 | 170174732.000 | 5557376.000 | 86829748.000 | 5894602.000 | 30.62 | 14.73 |
1. K-Means Clustering

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 4.000 | 18460.000 | 2.000 | 114.000 | 0.00 | 0.02 |
| 4 | 4.000 | 25272.000 | 2.000 | 155.000 | 0.00 | 0.01 |
| 8 | 4.000 | 21911.000 | 2.000 | 228.000 | 0.00 | 0.01 |
| 16 | 4.000 | 22508.000 | 2.000 | 416.000 | 0.00 | 0.00 |
| 32 | 4.000 | 20320.000 | 2.000 | 647.000 | 0.00 | 0.00 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 48.000 | 137985.000 | 59.000 | 835.000 | 0.00 | 0.07 |
| 4 | 48.000 | 133790.000 | 59.000 | 1081.000 | 0.00 | 0.05 |
| 8 | 48.000 | 142616.000 | 59.000 | 1344.000 | 0.00 | 0.04 |
| 16 | 48.000 | 109541.000 | 59.000 | 1960.000 | 0.00 | 0.03 |
| 32 | 48.000 | 114462.000 | 59.000 | 3711.000 | 0.00 | 0.02 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 878.000 | 223254.000 | 924.000 | 3674.000 | 0.00 | 0.25 |
| 4 | 878.000 | 213263.000 | 924.000 | 4533.000 | 0.00 | 0.20 |
| 8 | 878.000 | 199150.000 | 924.000 | 5894.000 | 0.00 | 0.16 |
| 16 | 878.000 | 187806.000 | 924.000 | 8521.000 | 0.00 | 0.11 |
| 32 | 878.000 | 135377.000 | 924.000 | 13751.000 | 0.01 | 0.07 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 14324.000 | 699265.000 | 18654.000 | 68793.000 | 0.02 | 0.27 |
| 4 | 14324.000 | 652882.000 | 18654.000 | 69600.000 | 0.02 | 0.27 |
| 8 | 14324.000 | 662613.000 | 18654.000 | 81559.000 | 0.02 | 0.23 |
| 16 | 14324.000 | 633384.000 | 18654.000 | 104000.000 | 0.02 | 0.18 |
| 32 | 14324.000 | 556072.000 | 18654.000 | 121969.000 | 0.03 | 0.15 |
1. Monte Carlo

---

Problem Size: 10

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 45.000 | 659.000 | 11.000 | 247.000 | 0.07 | 0.04 |
| 4 | 45.000 | 1133.000 | 11.000 | 41.000 | 0.04 | 0.27 |
| 8 | 45.000 | 1483.000 | 11.000 | 41.000 | 0.03 | 0.27 |
| 16 | 45.000 | 2135.000 | 11.000 | 31.000 | 0.02 | 0.35 |
| 32 | 45.000 | 3607.000 | 11.000 | 52.000 | 0.01 | 0.21 |

Problem Size: 100

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 51.000 | 606.000 | 18.000 | 139.000 | 0.08 | 0.13 |
| 4 | 51.000 | 810.000 | 18.000 | 35.000 | 0.06 | 0.51 |
| 8 | 51.000 | 1107.000 | 18.000 | 37.000 | 0.05 | 0.49 |
| 16 | 51.000 | 1771.000 | 18.000 | 37.000 | 0.03 | 0.49 |
| 32 | 51.000 | 3203.000 | 18.000 | 45.000 | 0.02 | 0.40 |

Problem Size: 1000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 89.000 | 658.000 | 36.000 | 85.000 | 0.14 | 0.42 |
| 4 | 89.000 | 886.000 | 36.000 | 99.000 | 0.10 | 0.36 |
| 8 | 89.000 | 1179.000 | 36.000 | 63.000 | 0.08 | 0.57 |
| 16 | 89.000 | 1830.000 | 36.000 | 57.000 | 0.05 | 0.63 |
| 32 | 89.000 | 3140.000 | 36.000 | 68.000 | 0.03 | 0.53 |

Problem Size: 10000

| Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | 450.000 | 990.000 | 219.000 | 361.000 | 0.45 | 0.61 |
| 4 | 450.000 | 1210.000 | 219.000 | 294.000 | 0.37 | 0.74 |
| 8 | 450.000 | 1546.000 | 219.000 | 299.000 | 0.29 | 0.73 |
| 16 | 450.000 | 2195.000 | 219.000 | 279.000 | 0.21 | 0.78 |
| 32 | 450.000 | 3427.000 | 219.000 | 287.000 | 0.13 | 0.76 |

Notes:

- All times are in microseconds (ms)
- Speedup = Sequential Time / Parallel Time
- Tests conducted with thread counts: 2 4 8 16 32
- Sequential times are shown for reference and are the same across all thread configurations