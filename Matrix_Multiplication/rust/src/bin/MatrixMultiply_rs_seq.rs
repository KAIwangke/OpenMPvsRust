use std::env;
use std::fs::File;
use std::io::{self, BufRead, BufReader, Write};
use std::time::Instant;

// Function to read a matrix from a file
fn read_matrix(filename: &str) -> io::Result<(Vec<Vec<i32>>, usize, usize)> {
    let file = File::open(filename)?;
    let mut reader = BufReader::new(file);

    // Read the dimensions of the matrix
    let mut dimensions = String::new();
    reader.read_line(&mut dimensions)?;
    let dims: Vec<usize> = dimensions
        .trim()
        .split_whitespace()
        .map(|x| x.parse().unwrap())
        .collect();
    let (rows, cols) = (dims[0], dims[1]);

    // Read the matrix data
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

// Function to write a matrix to a file
fn write_matrix(filename: &str, matrix: &Vec<Vec<i32>>) -> io::Result<()> {
    let mut file = File::create(filename)?;
    let rows = matrix.len();
    let cols = matrix[0].len();

    // Write the dimensions of the matrix
    writeln!(file, "{} {}", rows, cols)?;

    // Write the matrix data
    for row in matrix {
        for value in row {
            write!(file, "{} ", value)?;
        }
        writeln!(file)?;
    }

    Ok(())
}

// Sequential matrix multiplication
fn matrix_multiply_sequential(a: &Vec<Vec<i32>>, b: &Vec<Vec<i32>>) -> Vec<Vec<i32>> {
    let rows = a.len();
    let cols = b[0].len();
    let common_dim = a[0].len();

    let mut result = vec![vec![0; cols]; rows];

    for i in 0..rows {
        for j in 0..cols {
            for k in 0..common_dim {
                result[i][j] += a[i][k] * b[k][j];
            }
        }
    }

    result
}

fn main() -> io::Result<()> {
    // Parse command-line arguments
    let args: Vec<String> = env::args().collect();
    if args.len() != 4 {
        eprintln!("Usage: ./matrix_multiply_seq <matrix1_file> <matrix2_file> <output_file>");
        std::process::exit(1);
    }

    let matrix1_file = &args[1];
    let matrix2_file = &args[2];
    let output_file = &args[3];

    // Read input matrices
    let (a, rows_a, cols_a) = read_matrix(matrix1_file)?;
    let (b, rows_b, _cols_b) = read_matrix(matrix2_file)?;

    // Check if multiplication is valid
    if cols_a != rows_b {
        eprintln!("Error: Matrix dimensions do not allow multiplication.");
        std::process::exit(1);
    }

    // Record start time
    let start_time = Instant::now();

    // Perform matrix multiplication
    let result = matrix_multiply_sequential(&a, &b);

    // Record elapsed time
    let elapsed_time = start_time.elapsed();

    // Write result to output file
    write_matrix(output_file, &result)?;

    // Print output information
    println!("The matrix order N = {}", rows_a);
    println!(
        "Elapsed microseconds = {}",
        elapsed_time.as_micros()
    );

    Ok(())
}

/*
scp /Users/lidanwen/Desktop/multicore/project/Matrix_Multiplication/MatrixMultiply_rs_seq.rs dl5179@access.cims.nyu.edu:~/multicore/project/matrixmultiply
6AFwk?J*ZGSx#m
ssh dl5179@access.cims.nyu.edu
6AFwk?J*ZGSx#m
cd ~/multicore/project/matrixmultiply
rustc MatrixMultiply_rs_seq.rs -o MatrixMultiply_rs_seq -C opt-level=3
./MatrixMultiply_rs_seq matrix1_3.txt matrix2_3.txt output3_rs_seq.txt

./kmeans_rs_seq input_1000.txt out1000_rs_seq.txt 10
./kmeans_rs_seq input_10000.txt out10000_rs_seq.txt 10
./kmeans_rs_seq input_100000.txt out100000_rs_seq.txt 10
./kmeans_rs_seq input_1000000.txt out1000000_rs_seq.txt 10
cat output3_rs_seq.txt
*/