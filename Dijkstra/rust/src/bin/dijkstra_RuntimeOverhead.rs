use std::env;
use rand::Rng;
use rayon::prelude::*;
use std::time::{Instant, Duration};
use std::sync::atomic::{AtomicU64, Ordering};
use std::thread;

#[derive(Debug)]
struct TimingMetrics {
    thread_pool_creation: AtomicU64,
    thread_termination: AtomicU64,
    parallel_region_overhead: AtomicU64,
    join_overhead: AtomicU64,
    barrier_sync_time: AtomicU64,
    reduction_time: AtomicU64,
    scheduling_overhead: AtomicU64,
    memory_allocation_time: AtomicU64,
    data_distribution_time: AtomicU64,
    load_balancing_time: AtomicU64,
}

impl TimingMetrics {
    fn new() -> Self {
        TimingMetrics {
            thread_pool_creation: AtomicU64::new(0),
            thread_termination: AtomicU64::new(0),
            parallel_region_overhead: AtomicU64::new(0),
            join_overhead: AtomicU64::new(0),
            barrier_sync_time: AtomicU64::new(0),
            reduction_time: AtomicU64::new(0),
            scheduling_overhead: AtomicU64::new(0),
            memory_allocation_time: AtomicU64::new(0),
            data_distribution_time: AtomicU64::new(0),
            load_balancing_time: AtomicU64::new(0),
        }
    }

    fn print(&self) {
        println!("\nDetailed Rayon Timing Metrics (microseconds):");
        println!("1. Thread Pool Creation Overhead: {:.3}", self.thread_pool_creation.load(Ordering::Relaxed) as f64);
        println!("2. Thread Termination Overhead: {:.3}", self.thread_termination.load(Ordering::Relaxed) as f64);
        println!("3. Parallel Region Overhead: {:.3}", self.parallel_region_overhead.load(Ordering::Relaxed) as f64);
        println!("4. Join Overhead: {:.3}", self.join_overhead.load(Ordering::Relaxed) as f64);
        println!("5. Barrier Synchronization Time: {:.3}", self.barrier_sync_time.load(Ordering::Relaxed) as f64);
        println!("6. Reduction Operation Time: {:.3}", self.reduction_time.load(Ordering::Relaxed) as f64);
        println!("7. Scheduling Overhead: {:.3}", self.scheduling_overhead.load(Ordering::Relaxed) as f64);
        println!("8. Memory Allocation Time: {:.3}", self.memory_allocation_time.load(Ordering::Relaxed) as f64);
        println!("9. Data Distribution Time: {:.3}", self.data_distribution_time.load(Ordering::Relaxed) as f64);
        println!("10. Load Balancing Time: {:.3}", self.load_balancing_time.load(Ordering::Relaxed) as f64);
    }
}

fn measure_thread_pool(num_threads: usize, metrics: &TimingMetrics) {
    // Measure creation multiple times to get more accurate results
    for _ in 0..5 {
        let start = Instant::now();
        let pool = rayon::ThreadPoolBuilder::new()
            .num_threads(num_threads)
            .build()
            .unwrap();
        metrics.thread_pool_creation.fetch_add(
            start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );

        // Force some work to ensure threads are actually created
        pool.install(|| {
            (0..1000).into_par_iter().for_each(|_| {
                thread::sleep(Duration::from_nanos(1));
            });
        });

        let term_start = Instant::now();
        drop(pool);
        // Force synchronization to ensure threads are cleaned up
        rayon::scope(|_| {});
        metrics.thread_termination.fetch_add(
            term_start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );
    }
}

fn measure_barrier_sync(metrics: &TimingMetrics) {
    for _ in 0..10 {
        let start = Instant::now();
        rayon::scope(|s| {
            for _ in 0..4 {
                s.spawn(|_| {
                    // Simulate some work
                    thread::sleep(Duration::from_nanos(1));
                });
            }
        });
        metrics.barrier_sync_time.fetch_add(
            start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );
    }
}

fn measure_reduction(size: usize, metrics: &TimingMetrics) {
    let data: Vec<i32> = (0..size).map(|x| x as i32).collect();
    
    for _ in 0..5 {
        let start = Instant::now();
        let _result = data.par_iter()
            .map(|&x| {
                // Add meaningful work to measure
                let mut sum = 0;
                for i in 0..100 {
                    sum += (x + i) % 17;
                }
                sum
            })
            .sum::<i32>();
        
        metrics.reduction_time.fetch_add(
            start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );
    }
}

fn measure_join(size: usize, metrics: &TimingMetrics) {
    let mut data = vec![0; size];
    
    for _ in 0..5 {
        let start = Instant::now();
        
        // Split the data into two mutable slices
        let (left, right) = data.split_at_mut(size/2);
        
        rayon::join(
            || {
                left.iter_mut().for_each(|x| {
                    *x += 1;
                    thread::sleep(Duration::from_nanos(1));
                });
            },
            || {
                right.iter_mut().for_each(|x| {
                    *x += 1;
                    thread::sleep(Duration::from_nanos(1));
                });
            }
        );
        
        metrics.join_overhead.fetch_add(
            start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );
    }
}


fn min_distance(distances: &Vec<i32>, visited: &Vec<bool>, metrics: &TimingMetrics) -> Option<usize> {
    let par_start = Instant::now();
    let result = distances.par_iter()
        .enumerate()
        .filter(|(i, _)| !visited[*i])
        .min_by_key(|&(_, dist)| dist)
        .map(|(i, _)| i);
    
    metrics.parallel_region_overhead.fetch_add(
        par_start.elapsed().as_micros() as u64,
        Ordering::Relaxed
    );
    
    result
}

fn dijkstra(graph: &Vec<Vec<Option<usize>>>, start: usize, size: usize, metrics: &TimingMetrics) -> Vec<i32> {
    let alloc_start = Instant::now();
    let mut distances = vec![i32::MAX; size];
    let mut visited = vec![false; size];
    metrics.memory_allocation_time.fetch_add(
        alloc_start.elapsed().as_micros() as u64,
        Ordering::Relaxed
    );

    let dist_start = Instant::now();
    distances.par_iter_mut().for_each(|d| *d = i32::MAX);
    visited.par_iter_mut().for_each(|v| *v = false);
    metrics.data_distribution_time.fetch_add(
        dist_start.elapsed().as_micros() as u64,
        Ordering::Relaxed
    );

    distances[start] = 0;

    for _ in 0..size - 1 {
        let sched_start = Instant::now();
        let u = match min_distance(&distances, &visited, metrics) {
            Some(u) => u,
            None => break,
        };
        metrics.scheduling_overhead.fetch_add(
            sched_start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );

        if distances[u] == i32::MAX {
            break;
        }

        visited[u] = true;

        let balance_start = Instant::now();
        let updates: Vec<(usize, i32)> = graph[u].par_iter()
            .enumerate()
            .filter_map(|(v, &weight)| {
                if let Some(w) = weight {
                    if !visited[v] && distances[u] != i32::MAX {
                        let next_distance = distances[u] + w as i32;
                        if next_distance < distances[v] {
                            Some((v, next_distance))
                        } else {
                            None
                        }
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
            .collect();
        
        metrics.load_balancing_time.fetch_add(
            balance_start.elapsed().as_micros() as u64,
            Ordering::Relaxed
        );

        for (v, dist) in updates {
            distances[v] = dist;
        }
    }

    distances
}

fn generate_graph(num_vertices: usize, max_weight: usize) -> Vec<Vec<Option<usize>>> {
    let mut graph = vec![vec![None; num_vertices]; num_vertices];
    
    for i in 0..num_vertices {
        for j in 0..num_vertices {
            if i != j {
                let mut rng = rand::thread_rng();
                if rng.gen_bool(0.7) {
                    graph[i][j] = Some(rng.gen_range(1..=max_weight));
                }
            }
        }
    }

    graph
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 || args.len() > 3 {
        eprintln!("Usage: {} <graph_size> [num_threads]", args[0]);
        std::process::exit(1);
    }

    let size: usize = match args[1].parse() {
        Ok(n) if n > 0 => n,
        _ => {
            eprintln!("Error: <graph_size> must be a positive integer.");
            std::process::exit(1);
        }
    };

    let num_threads = if args.len() == 3 {
        match args[2].parse() {
            Ok(n) if n > 0 => n,
            _ => {
                eprintln!("Error: [num_threads] must be a positive integer.");
                std::process::exit(1);
            }
        }
    } else {
        rayon::current_num_threads()
    };

    let metrics = TimingMetrics::new();

    // Measure thread operations
    measure_thread_pool(num_threads, &metrics);
    
    // Measure barrier synchronization
    measure_barrier_sync(&metrics);
    
    // Measure reduction operation
    measure_reduction(size, &metrics);
    
    // Measure join overhead
    measure_join(size, &metrics);

    let max_weight = 20;
    let start_vertex = 0;
    let graph = generate_graph(size, max_weight);

    println!(
        "Running parallel Dijkstra's algorithm with graph size {}x{} using {} threads...",
        size, size, num_threads
    );

    let start = Instant::now();
    let _distances = dijkstra(&graph, start_vertex, size, &metrics);
    let duration = start.elapsed();

    println!(
        "Total Execution Time: {:.3} microseconds",
        duration.as_micros()
    );
    
    // Print averaged metrics
    metrics.print();
}