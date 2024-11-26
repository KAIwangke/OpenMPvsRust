use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};
use std::time::Instant;

// Function to calculate the 1D index in a flattened 2D array
fn index(i: usize, j: usize, cols: usize) -> usize {
    i * cols + j
}

// Struct to represent the K-Means algorithm
struct KMeans {
    n: usize,             // Number of points
    k: usize,             // Number of clusters
    points: Vec<f32>,     // Flattened array storing points (x, y)
    centroids: Vec<f32>,  // Flattened array storing centroids (x, y)
    clusters: Vec<usize>, // Cluster index for each point
    iterations: usize,    // Number of iterations
}

impl KMeans {
    // Constructor to initialize the KMeans struct
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

    // Function to read input data from a file
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

    // Function to initialize centroids with the first K points
    fn generate_initial_centroids(&mut self) {
        self.centroids = vec![0.0; self.k * 2];
        for i in 0..self.k {
            self.centroids[index(i, 0, 2)] = self.points[index(i, 0, 2)];
            self.centroids[index(i, 1, 2)] = self.points[index(i, 1, 2)];
        }
    }

    // Function to assign points to the nearest cluster
    fn assign_points_to_clusters(&mut self) -> bool {
        let mut cluster_changed = false;

        for i in 0..self.n {
            let mut min_dist = f32::MAX;
            let mut closest_centroid = 0;

            for j in 0..self.k {
                let dx = self.centroids[index(j, 0, 2)] - self.points[index(i, 0, 2)];
                let dy = self.centroids[index(j, 1, 2)] - self.points[index(i, 1, 2)];
                let dist = dx * dx + dy * dy;

                if dist < min_dist {
                    min_dist = dist;
                    closest_centroid = j;
                }
            }

            if self.clusters[i] != closest_centroid {
                cluster_changed = true;
                self.clusters[i] = closest_centroid;
            }
        }

        cluster_changed
    }

    // Function to recalculate centroids based on cluster assignments
    fn calculate_new_centroids(&mut self) {
        let mut sum_x = vec![0.0; self.k];
        let mut sum_y = vec![0.0; self.k];
        let mut count = vec![0; self.k];

        for i in 0..self.n {
            let cluster = self.clusters[i];
            sum_x[cluster] += self.points[index(i, 0, 2)];
            sum_y[cluster] += self.points[index(i, 1, 2)];
            count[cluster] += 1;
        }

        for i in 0..self.k {
            if count[i] > 0 {
                self.centroids[index(i, 0, 2)] = sum_x[i] / count[i] as f32;
                self.centroids[index(i, 1, 2)] = sum_y[i] / count[i] as f32;
            }
        }
    }

    // Function to write results to a file
    fn print_results(&self, filename: &str) -> io::Result<()> {
        let mut file = File::create(filename)?;
        writeln!(file, "Total Iterations: {}", self.iterations)?;
        writeln!(file, "Number of Points: {}", self.n)?;
        writeln!(file, "Centroids:")?;
        for i in 0..self.k {
            writeln!(
                file,
                "{}, {}",
                self.centroids[index(i, 0, 2)],
                self.centroids[index(i, 1, 2)]
            )?;
        }
        writeln!(file, "Point Assignments:")?;
        for cluster in &self.clusters {
            write!(file, "{} ", cluster)?;
        }
        Ok(())
    }

    // Function to execute the K-Means algorithm
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
        eprintln!("Usage: kmeans_rs_seq input_file output_file K(optional)");
        std::process::exit(1);
    }

    let input_filename = &args[1];
    let output_filename = &args[2];
    let k = if args.len() > 3 {
        args[3].parse::<usize>().unwrap_or(3)
    } else {
        3
    };

    let mut kmeans = KMeans::new(k);

    kmeans.read_input_file(input_filename)?;
    kmeans.clusters = vec![0; kmeans.n];
    kmeans.generate_initial_centroids();

    // Measure execution time
    let start_time = Instant::now();
    kmeans.run();
    let elapsed_time = start_time.elapsed();

    kmeans.print_results(output_filename)?;

    // Print execution time in microseconds
    println!("{}", elapsed_time.as_micros());

    Ok(())
}

/*
scp /Users/lidanwen/Desktop/multicore/project/kmeans/kmeans_rs_seq.rs dl5179@access.cims.nyu.edu:~/multicore/project/kmeans
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/kmeans
rustc kmeans_rs_seq.rs -o kmeans_rs_seq -C opt-level=3
./kmeans_rs_seq input_1000.txt out1000_rs_seq.txt 10
./kmeans_rs_seq input_10000.txt out10000_rs_seq.txt 10
./kmeans_rs_seq input_100000.txt out100000_rs_seq.txt 10
./kmeans_rs_seq input_1000000.txt out1000000_rs_seq.txt 10
cat out1000_rs_seq.txt
*/