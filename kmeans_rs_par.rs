use rayon::prelude::*;
use rayon::ThreadPoolBuilder;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};
use std::sync::Mutex;
use std::time::Instant;
use std::f32::MAX as FLT_MAX;

fn index(i: usize, j: usize, cols: usize) -> usize {
    i * cols + j
}

struct KMeans {
    n: usize,             // Number of points
    k: usize,             // Number of clusters
    points: Vec<f32>,     // Flattened array storing points (x, y)
    centroids: Vec<f32>,  // Flattened array storing centroids (x, y)
    clusters: Vec<usize>, // Cluster index for each point
    iterations: usize,    // Number of iterations
}

impl KMeans {
    fn new(k: usize) -> Self {
        Self {
            n: 0,
            k,
            points: Vec::new(),
            centroids: Vec::new(),
            clusters: Vec::new(),
            iterations: 0,
        }
    }

    fn read_input_file(&mut self, filename: &str) -> io::Result<()> {
        let file = File::open(filename)?;
        let reader = BufReader::new(file);

        let mut lines = reader.lines();
        self.n = lines
            .next()
            .ok_or(io::Error::new(io::ErrorKind::InvalidData, "File is empty"))??
            .parse::<usize>()
            .map_err(|_| io::Error::new(io::ErrorKind::InvalidData, "Invalid number of points"))?;

        self.points = vec![0.0; self.n * 2];
        for (i, line) in lines.enumerate() {
            let coords: Vec<f32> = line?
                .split_whitespace()
                .map(|x| x.parse::<f32>().unwrap())
                .collect();
            self.points[index(i, 0, 2)] = coords[0];
            self.points[index(i, 1, 2)] = coords[1];
        }
        Ok(())
    }

    fn generate_initial_centroids(&mut self) {
        self.centroids = vec![0.0; self.k * 2];
        for i in 0..self.k {
            self.centroids[index(i, 0, 2)] = self.points[index(i, 0, 2)];
            self.centroids[index(i, 1, 2)] = self.points[index(i, 1, 2)];
        }
    }

    fn assign_points_to_clusters(&mut self) -> bool {
        let mut cluster_changed = false;

        let new_clusters: Vec<usize> = self
            .points
            .par_chunks(2)
            .map(|point| {
                let mut min_dist = FLT_MAX;
                let mut closest_centroid = 0;

                for j in 0..self.k {
                    let dx = self.centroids[index(j, 0, 2)] - point[0];
                    let dy = self.centroids[index(j, 1, 2)] - point[1];
                    let dist = dx * dx + dy * dy;
                    if dist < min_dist {
                        min_dist = dist;
                        closest_centroid = j;
                    }
                }
                closest_centroid
            })
            .collect();

        for (i, &new_cluster) in new_clusters.iter().enumerate() {
            if self.clusters[i] != new_cluster {
                cluster_changed = true;
                self.clusters[i] = new_cluster;
            }
        }

        cluster_changed
    }

    fn calculate_new_centroids(&mut self) {
        let local_sums: Vec<Mutex<(f32, f32, usize)>> = (0..self.k)
            .map(|_| Mutex::new((0.0, 0.0, 0)))
            .collect();

        self.points.par_chunks(2).enumerate().for_each(|(i, point)| {
            let cluster = self.clusters[i];
            let mut cluster_sum = local_sums[cluster].lock().unwrap();
            cluster_sum.0 += point[0];
            cluster_sum.1 += point[1];
            cluster_sum.2 += 1;
        });

        for (i, sum) in local_sums.iter().enumerate() {
            let (x_sum, y_sum, count) = *sum.lock().unwrap();
            if count > 0 {
                self.centroids[index(i, 0, 2)] = x_sum / count as f32;
                self.centroids[index(i, 1, 2)] = y_sum / count as f32;
            }
        }
    }

    fn print_results(&self, filename: &str) -> io::Result<()> {
        let mut file = File::create(filename)?;
        writeln!(file, "Total iterations taken = {}", self.iterations)?;
        writeln!(file, "Number of points N = {}", self.n)?;
        writeln!(file, "Centroids are:")?;
        for i in 0..self.k {
            writeln!(
                file,
                "{}, {}",
                self.centroids[index(i, 0, 2)],
                self.centroids[index(i, 1, 2)]
            )?;
        }
        writeln!(file, "Cluster indices of points are:")?;
        for cluster in &self.clusters {
            write!(file, "{} ", cluster)?;
        }
        Ok(())
    }

    fn run(&mut self) {
        let mut change_flag = true;
        while change_flag {
            change_flag = self.assign_points_to_clusters();
            self.calculate_new_centroids();
            self.iterations += 1;
        }
    }
}

fn main() -> io::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: kmeans_rs_par input_file output_file [cluster_count] [thread_count]");
        std::process::exit(1);
    }

    let input_filename = &args[1];
    let output_filename = &args[2];
    let cluster_count = if args.len() > 3 {
        args[3].parse::<usize>().unwrap_or(3)
    } else {
        3
    };
    let thread_count = if args.len() > 4 {
        args[4].parse::<usize>().unwrap_or(1)
    } else {
        1
    };

    // Configure thread pool
    ThreadPoolBuilder::new()
        .num_threads(thread_count)
        .build_global()
        .unwrap();

    let mut kmeans = KMeans::new(cluster_count);

    kmeans.read_input_file(input_filename)?;
    kmeans.clusters = vec![0; kmeans.n];
    kmeans.generate_initial_centroids();

    let start_time = Instant::now();
    kmeans.run();
    let elapsed_time = start_time.elapsed();

    kmeans.print_results(output_filename)?;

    println!("Time taken = {} microseconds", elapsed_time.as_micros());
    println!("Cluster count: {}, Thread count: {}", cluster_count, thread_count);
    Ok(())
}



/*
scp /Users/lidanwen/Desktop/multicore/project/kmeans/kmeans_rs_par.rs dl5179@access.cims.nyu.edu:~/multicore/project/kmeans
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/kmeans
cargo build
cp ./target/debug/kmeans_rs_par ~/multicore/project/kmeans/
./kmeans_rs_par input_1000.txt output1000_rs_par.txt 10
./kmeans_rs_par input_10000.txt output10000_rs_par.txt 10
./kmeans_rs_par input_100000.txt output100000_rs_par.txt 10
./kmeans_rs_par input_1000000.txt output1000000_rs_par.txt 10
*/