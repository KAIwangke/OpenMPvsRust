use rand::Rng;
use std::env;
use std::time::Instant;

fn estimate_pi(num_points: u64) -> f64 {
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

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        std::process::exit(1);
    }

    let num_points: u64 = match args[1].parse() {
        Ok(n) => n,
        Err(_) => {
            std::process::exit(1);
        }
    };

    let start = Instant::now();
    let pi_estimate = estimate_pi(num_points);
    let duration = start.elapsed();

    println!("{}", duration.as_micros());
    
}