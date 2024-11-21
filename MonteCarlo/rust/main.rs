use rand::Rng;
use rayon::prelude::*;
use std::env;
use std::time::Instant;

// Parallel version of Monte Carlo π estimation
fn estimate_pi_parallel(num_points: u64) -> f64 {
    // Split into chunks for better cache utilization
    let chunk_size = 10000; // Fixed chunk size for better performance
    let num_chunks = (num_points as usize + chunk_size - 1) / chunk_size;
    
    let points_inside: u64 = (0..num_chunks)
        .into_par_iter()
        .map(|_| {
            let mut rng = rand::thread_rng();
            let points_this_chunk = chunk_size.min(num_points as usize);
            let mut count = 0;
            
            for _ in 0..points_this_chunk {
                let x: f64 = rng.gen();
                let y: f64 = rng.gen();
                if x * x + y * y <= 1.0 {
                    count += 1;
                }
            }
            count as u64
        })
        .sum();
    
    4.0 * points_inside as f64 / num_points as f64
}

// Non-parallel version of Monte Carlo π estimation
fn estimate_pi_non_parallel(num_points: u64) -> f64 {
    let mut rng = rand::thread_rng();
    let mut points_inside = 0;
    
    for _ in 0..num_points {
        let x: f64 = rng.gen();
        let y: f64 = rng.gen();
        if x * x + y * y <= 1.0 {
            points_inside += 1;
        }
    }
    
    4.0 * points_inside as f64 / num_points as f64
}

fn run_benchmark(num_points: u64, parallel: bool) {
    // Initialize the thread pool once
    if parallel {
        rayon::ThreadPoolBuilder::new()
            .build_global()
            .unwrap();
    }

    let start = Instant::now();
    let pi_estimate = if parallel {
        estimate_pi_parallel(num_points)
    } else {
        estimate_pi_non_parallel(num_points)
    };
    let duration = start.elapsed();
    
    let error = (pi_estimate - std::f64::consts::PI).abs();
    
    println!("Estimated π: {}", pi_estimate);
    println!("Actual π: {}", std::f64::consts::PI);
    println!("Error: {}", error);
    println!("Time taken: {:.6}", duration.as_secs_f64());
}

fn main() {
    let args: Vec<String> = env::args().collect();
    
    if args.len() != 3 {
        eprintln!("Usage: {} <parallel|sequential> <num_points>", args[0]);
        std::process::exit(1);
    }
    
    let parallel = match args[1].as_str() {
        "parallel" => true,
        "sequential" => false,
        _ => {
            eprintln!("First argument must be either 'parallel' or 'sequential'");
            std::process::exit(1);
        }
    };
    
    let num_points: u64 = match args[2].parse() {
        Ok(n) => n,
        Err(_) => {
            eprintln!("Second argument must be a valid number");
            std::process::exit(1);
        }
    };
    
    run_benchmark(num_points, parallel);
}