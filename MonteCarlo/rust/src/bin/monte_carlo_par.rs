use rand::Rng;
use rayon::prelude::*;
use std::env;
use std::time::Instant;

fn estimate_pi(num_points: u64) -> f64 {
    let chunk_size = 10_000;
    let num_chunks = (num_points as usize + chunk_size - 1) / chunk_size;

    let points_inside: u64 = (0..num_chunks)
        .into_par_iter()
        .map(|chunk_index| {
            let mut rng = rand::thread_rng();
            let start = chunk_index * chunk_size;
            let end = ((chunk_index + 1) * chunk_size).min(num_points as usize);
            let points_this_chunk = end - start;

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

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 || args.len() > 3 {
        eprintln!("Usage: {} <num_points> [num_threads]", args[0]);
        std::process::exit(1);
    }

    let num_points: u64 = match args[1].parse() {
        Ok(n) if n > 0 => n,
        _ => {
            eprintln!("Number of points must be positive.");
            std::process::exit(1);
        }
    };

    let num_threads = if args.len() == 3 {
        match args[2].parse::<usize>() {
            Ok(n) if n > 0 => n,
            _ => {
                eprintln!("Number of threads must be positive.");
                std::process::exit(1);
            }
        }
    } else {
        rayon::current_num_threads()
    };

    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(num_threads)
        .build()
        .expect("Failed to build thread pool");

    let start = Instant::now();
    let pi_estimate = pool.install(|| estimate_pi(num_points));
    let duration = start.elapsed();

    println!("Time taken: {} microseconds", duration.as_micros());
}