use rayon::prelude::*;
use rayon::ThreadPoolBuilder;
use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};
use std::time::Instant;

fn read_matrix(filename: &str) -> io::Result<(Vec<Vec<i32>>, usize, usize)> {
    let file = File::open(filename)?;
    let mut reader = BufReader::new(file);

    let mut dimensions = String::new();
    reader.read_line(&mut dimensions)?;
    let dims: Vec<usize> = dimensions
        .trim()
        .split_whitespace()
        .map(|x| x.parse().unwrap())
        .collect();
    let (rows, cols) = (dims[0], dims[1]);

    let mut matrix = Vec::new();
    for line in reader.lines() {
        let row: Vec<i32> = line?
            .split_whitespace()
            .map(|x| x.parse::<i32>().unwrap())
            .collect();
        matrix.push(row);
    }

    Ok((matrix, rows, cols))
}

fn write_matrix(filename: &str, matrix: &Vec<Vec<i32>>) -> io::Result<()> {
    let mut file = File::create(filename)?;
    let rows = matrix.len();
    let cols = matrix[0].len();

    writeln!(file, "{} {}", rows, cols)?;

    for row in matrix {
        for value in row {
            write!(file, "{} ", value)?;
        }
        writeln!(file)?;
    }

    Ok(())
}

fn matrix_multiply_parallel(a: &Vec<Vec<i32>>, b: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = a.len();
    let cols = b[0].len();
    let common_dim = a[0].len();

    let mut result = vec![vec![0; cols]; rows];

    result
        .par_iter_mut()
        .enumerate()
        .for_each(|(i, row)| {
            for j in 0..cols {
                let mut sum = 0;
                for k in 0..common_dim {
                    sum += a[i][k] * b[k][j];
                }
                row[j] = sum;
            }
        });

    result
}

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() < 4 || args.len() > 5 {
        std::process::exit(1);
    }

    let matrix1_file = &args[1];
    let matrix2_file = &args[2];
    let output_file = &args[3];
    let num_threads: usize = if args.len() == 5 {
        args[4].parse().unwrap_or(1) // Parse thread count, default to 1
    } else {
        1
    };

    // Configure the rayon thread pool
    ThreadPoolBuilder::new()
        .num_threads(num_threads)
        .build_global()
        .unwrap();

    // Print thread count

    let (a, rows_a, cols_a) = read_matrix(matrix1_file)?;
    let (b, rows_b, _cols_b) = read_matrix(matrix2_file)?;

    if cols_a != rows_b {
        std::process::exit(1);
    }

    let start_time = Instant::now();
    let result = matrix_multiply_parallel(&a, &b);
    let elapsed_time = start_time.elapsed();

    write_matrix(output_file, &result)?;

    println!("{}", elapsed_time.as_micros());


    Ok(())
}




/*
scp /Users/lidanwen/Desktop/multicore/project/Matrix_Multiplication/MatrixMultiply_rs_par.rs dl5179@access.cims.nyu.edu:~/multicore/project/matrixmultiply
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/matrixmultiply
mv MatrixMultiply_rs_par.rs src/main.rs
cargo build --release
./target/release/MatrixMultiply_rs_par matrix1_3.txt matrix2_3.txt output3_rs_par.txt

cat output3_rs_seq.txt
*/