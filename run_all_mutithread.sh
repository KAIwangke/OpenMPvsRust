#!/bin/bash

# Debug and configuration flags
DEBUG=false
VERBOSE_OUTPUT=false  # Set to true to see more detailed processing information

# Time unit conversion constants
SECONDS_TO_MICROSECONDS=1000000


# run_all_mutithread.sh
# A comprehensive script to generate inputs, compile C++ and Rust code, run all executables, and collect results.

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display informational messages
function echo_info {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# Function to display error messages
function echo_error {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

# Function to display warning messages
function echo_warn {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# Create a results directory with timestamp to store all outputs
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_DIR="results_$TIMESTAMP"
mkdir -p "$RESULTS_DIR"

# Define problem sizes for each algorithm
PROBLEM_SIZES=(10 100)
Dijkstra_SIZES=(10 100)
MC_SIZES=(10 100)
KMeans_SIZES=(10 100)
Matrix_Multiplication_SIZES=(10 100)

# Define number of clusters for KMeans
KMEANS_CLUSTERS=10

# Define thread configurations to test
THREAD_CONFIGS=(2 4 8 16 32)


generate_matrix_if_not_exists() {
    local size=$1
    local dir="Matrix_Multiplication"
    local file1="${dir}/matrix1_${size}.txt"
    local file2="${dir}/matrix2_${size}.txt"

    if [[ -f "$file1" && -f "$file2" ]]; then
        echo_info "Matrices for size $size already exist. Skipping generation."
    else
        echo_info "Generating matrices for size $size..."
        (
            cd "$dir"
            ./generate_matrix_input "$size"
        )
    fi
}

generate_kmeans_if_not_exists() {
    local size=$1
    local dir="kmeans"
    local file="${dir}/input_${size}.txt"

    if [[ -f "$file" ]]; then
        echo_info "K-Means input for size $size already exists. Skipping generation."
    else
        echo_info "Generating K-Means input for size $size..."
        (
            cd "$dir"
            ./generate_kmeans_input "$size"
        )
    fi
}

# Function to compile C++ input generators
compile_input_generators() {
    echo_info "Compiling input generation executables..."

    # Compile Matrix Multiplication Input Generator
    MATRIX_INPUT_SRC="Matrix_Multiplication/generate_matrix_input.cpp"
    MATRIX_INPUT_EXE="Matrix_Multiplication/generate_matrix_input"
    if [[ -f "$MATRIX_INPUT_SRC" ]]; then
        echo_info "Compiling Matrix Multiplication input generator..."
        g++ "$MATRIX_INPUT_SRC" -o "$MATRIX_INPUT_EXE" -std=c++11 -O3
        chmod +x "$MATRIX_INPUT_EXE"
        echo_info "Compiled $MATRIX_INPUT_EXE successfully."
    else
        echo_error "Source file $MATRIX_INPUT_SRC not found. Please ensure it exists."
        exit 1
    fi

    # Compile K-Means Input Generator
    KMEANS_INPUT_SRC="kmeans/generate_kmeans_input.cpp"
    KMEANS_INPUT_EXE="kmeans/generate_kmeans_input"
    if [[ -f "$KMEANS_INPUT_SRC" ]]; then
        echo_info "Compiling K-Means input generator..."
        g++ "$KMEANS_INPUT_SRC" -o "$KMEANS_INPUT_EXE" -std=c++11 -O3
        chmod +x "$KMEANS_INPUT_EXE"
        echo_info "Compiled $KMEANS_INPUT_EXE successfully."
    else
        echo_error "Source file $KMEANS_INPUT_SRC not found. Please ensure it exists."
        exit 1
    fi
}

# Function to compile C++ code (Parallel and Sequential)
compile_cpp() {
    PROJECT_DIR=$1
    EXECUTABLE_PAR=$2
    SOURCE_FILE_PAR=$3
    EXECUTABLE_SEQ=$4
    SOURCE_FILE_SEQ=$5

    echo_info "Compiling $PROJECT_DIR C++ Parallel version..."
    g++ "$PROJECT_DIR/cpp/$SOURCE_FILE_PAR" -o "$PROJECT_DIR/cpp/$EXECUTABLE_PAR" -std=c++11 -O3 -fopenmp

    echo_info "Compiling $PROJECT_DIR C++ Sequential version..."
    g++ "$PROJECT_DIR/cpp/$SOURCE_FILE_SEQ" -o "$PROJECT_DIR/cpp/$EXECUTABLE_SEQ" -std=c++11 -O3
}

# Function to compile Rust code
compile_rust() {
    PROJECT_DIR=$1
    BIN_NAME=$2

    echo_info "Compiling Rust project $PROJECT_DIR: $BIN_NAME..."
    CARGO_TOML_PATH="$PROJECT_DIR/rust/Cargo.toml"
    if [[ -f "$CARGO_TOML_PATH" ]]; then
        cargo build --release --manifest-path "$CARGO_TOML_PATH" --bin "$BIN_NAME"
        echo_info "Compiled Rust binary $BIN_NAME successfully."
    else
        echo_error "Cargo.toml not found in $PROJECT_DIR/rust/. Please ensure the Rust project is set up correctly."
        exit 1
    fi
}

# Separate run functions for Parallel and Sequential Executables

# C++ Parallel Run Function
run_cpp_parallel() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${SIZE}_threads${THREADS}.txt"

    echo_info "Running C++ $EXECUTABLE with size $SIZE and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $SIZE $THREADS > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" "$THREADS" > "$output_file"
}

# C++ Sequential Run Function
run_cpp_sequential() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    SIZE=$3

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${SIZE}_threads1.txt"

    echo_info "Running C++ $EXECUTABLE with size $SIZE and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $SIZE > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" > "$output_file"
}

# Rust Parallel Run Function
run_rust_parallel() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${SIZE}_threads${THREADS}.txt"

    echo_info "Running Rust $BIN_NAME with size $SIZE and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $SIZE $THREADS > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" "$THREADS" > "$output_file"
}

# Rust Sequential Run Function
run_rust_sequential() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    SIZE=$3

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${SIZE}_threads1.txt"

    echo_info "Running Rust $BIN_NAME with size $SIZE and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $SIZE > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" > "$output_file"
}

# Run C++ K-Means Parallel
run_cpp_kmeans_parallel() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5
    THREADS=$6

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$INPUT_FILE" .txt)_threads${THREADS}.txt"

    echo_info "Running C++ $EXECUTABLE with input $INPUT_FILE, clusters $CLUSTERS, and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $INPUT_FILE $OUTPUT_FILE $CLUSTERS $THREADS > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" "$THREADS" > "$output_file"
}

# Run C++ K-Means Sequential
run_cpp_kmeans_sequential() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$INPUT_FILE" .txt)_threads1.txt"

    echo_info "Running C++ $EXECUTABLE with input $INPUT_FILE, clusters $CLUSTERS, and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $INPUT_FILE $OUTPUT_FILE $CLUSTERS > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" > "$output_file"
}

# Run Rust K-Means Parallel
run_rust_kmeans_parallel() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5
    THREADS=$6

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_par_$(basename "$INPUT_FILE" .txt)_threads${THREADS}.txt"

    echo_info "Running Rust $BIN_NAME in parallel mode with input $INPUT_FILE, clusters $CLUSTERS, and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $INPUT_FILE $OUTPUT_FILE $CLUSTERS $THREADS > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" "$THREADS" > "$output_file"
}

# Run Rust K-Means Sequential
run_rust_kmeans_sequential() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_seq_$(basename "$INPUT_FILE" .txt)_threads1.txt"

    echo_info "Running Rust $BIN_NAME in sequential mode with input $INPUT_FILE, clusters $CLUSTERS, and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $INPUT_FILE $OUTPUT_FILE $CLUSTERS > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" > "$output_file"
}

# Run C++ Matrix Multiplication Parallel
run_cpp_matrix_parallel() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5
    THREADS=$6

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$MATRIX1")_threads${THREADS}.txt"

    echo_info "Running C++ $EXECUTABLE with matrices $MATRIX1 and $MATRIX2 and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $MATRIX1 $MATRIX2 $OUTPUT_FILE $THREADS > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$MATRIX1" "$MATRIX2" "$OUTPUT_FILE" "$THREADS" > "$output_file" 2>&1
}

# Run C++ Matrix Multiplication Sequential
run_cpp_matrix_sequential() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$MATRIX1")_threads1.txt"

    echo_info "Running C++ $EXECUTABLE with matrices $MATRIX1 and $MATRIX2 and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/cpp/$EXECUTABLE $MATRIX1 $MATRIX2 $OUTPUT_FILE > $output_file"
    ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$MATRIX1" "$MATRIX2" "$OUTPUT_FILE" > "$output_file" 2>&1
}

# Run Rust Matrix Multiplication Parallel
run_rust_matrix_parallel() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5
    THREADS=$6

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_$(basename "$MATRIX1")_threads${THREADS}.txt"

    echo_info "Running Rust $BIN_NAME with matrices $MATRIX1 and $MATRIX2 and threads $THREADS..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $MATRIX1 $MATRIX2 $OUTPUT_FILE $THREADS > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$MATRIX1" "$MATRIX2" "$OUTPUT_FILE" "$THREADS" > "$output_file" 2>&1
}

# Run Rust Matrix Multiplication Sequential
run_rust_matrix_sequential() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_$(basename "$MATRIX1")_threads1.txt"

    echo_info "Running Rust $BIN_NAME with matrices $MATRIX1 and $MATRIX2 and threads 1..."
    # Debug: Show the command being executed
    echo_info "Command: ./$PROJECT_DIR/rust/target/release/$BIN_NAME $MATRIX1 $MATRIX2 $OUTPUT_FILE > $output_file"
    ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$MATRIX1" "$MATRIX2" "$OUTPUT_FILE" > "$output_file" 2>&1
}

# Main execution flow
compile_input_generators

# Generate all input files
echo_info "Generating input files..."
for size in "${Matrix_Multiplication_SIZES[@]}"; do
    generate_matrix_if_not_exists "$size"
done

for size in "${KMeans_SIZES[@]}"; do
    generate_kmeans_if_not_exists "$size"
done

# Compile all projects
echo_info "Compiling all projects..."
compile_cpp "Dijkstra" "dijkstra_par" "dijkstra_par.cpp" "dijkstra_seq" "dijkstra_seq.cpp"
compile_cpp "Matrix_Multiplication" "MatrixMultiply_omp_par" "MatrixMultiply_omp_par.cpp" "MatrixMultiply_cpp_seq" "MatrixMultiply_cpp_seq.cpp"
compile_cpp "kmeans" "kmeans_omp_par" "kmeans_omp_par.cpp" "kmeans_cpp_seq" "kmeans_cpp_seq.cpp"
compile_cpp "MonteCarlo" "monte_carlo_par" "monte_carlo_omp_par.cpp" "monte_carlo_seq" "monte_carlo_cpp_seq.cpp"

compile_rust "Dijkstra" "dijkstra_par"
compile_rust "Dijkstra" "dijkstra_seq"
compile_rust "Matrix_Multiplication" "MatrixMultiply_rs_par"
compile_rust "Matrix_Multiplication" "MatrixMultiply_rs_seq"
compile_rust "kmeans" "kmeans_rs_par"
compile_rust "kmeans" "kmeans_rs_seq"
compile_rust "MonteCarlo" "monte_carlo_par"
compile_rust "MonteCarlo" "monte_carlo_seq"

# Run experiments with different thread configurations
for THREADS in "${THREAD_CONFIGS[@]}"; do
    echo_info "Running experiments with $THREADS threads..."

    # Dijkstra
    for size in "${Dijkstra_SIZES[@]}"; do
        # C++ Parallel
        run_cpp_parallel "Dijkstra" "dijkstra_par" "$size" "$THREADS"
        # C++ Sequential
        run_cpp_sequential "Dijkstra" "dijkstra_seq" "$size"
        # Rust Parallel
        run_rust_parallel "Dijkstra" "dijkstra_par" "$size" "$THREADS"
        # Rust Sequential
        run_rust_sequential "Dijkstra" "dijkstra_seq" "$size"
    done

    # Monte Carlo
    for size in "${MC_SIZES[@]}"; do
        # C++ Parallel
        run_cpp_parallel "MonteCarlo" "monte_carlo_par" "$size" "$THREADS"
        # C++ Sequential
        run_cpp_sequential "MonteCarlo" "monte_carlo_seq" "$size"
        # Rust Parallel
        run_rust_parallel "MonteCarlo" "monte_carlo_par" "$size" "$THREADS"
        # Rust Sequential
        run_rust_sequential "MonteCarlo" "monte_carlo_seq" "$size"
    done

    # K-Means
    for size in "${KMeans_SIZES[@]}"; do
        input_file="kmeans/input_${size}.txt"
        output_cpp_par="kmeans/out${size}_omp_par.txt"
        output_cpp_seq="kmeans/out${size}_cpp_seq.txt"
        output_rs_par="kmeans/out${size}_rs_par.txt"
        output_rs_seq="kmeans/out${size}_rs_seq.txt"

        # C++ Parallel
        run_cpp_kmeans_parallel "kmeans" "kmeans_omp_par" "$input_file" "$output_cpp_par" "$KMEANS_CLUSTERS" "$THREADS"
        # C++ Sequential
        run_cpp_kmeans_sequential "kmeans" "kmeans_cpp_seq" "$input_file" "$output_cpp_seq" "$KMEANS_CLUSTERS"
        # Rust Parallel
        run_rust_kmeans_parallel "kmeans" "kmeans_rs_par" "$input_file" "$output_rs_par" "$KMEANS_CLUSTERS" "$THREADS"
        # Rust Sequential
        run_rust_kmeans_sequential "kmeans" "kmeans_rs_seq" "$input_file" "$output_rs_seq" "$KMEANS_CLUSTERS"
    done

    # Matrix Multiplication
    for size in "${Matrix_Multiplication_SIZES[@]}"; do
        # Skip size 10000 for matrix multiplication
        if [ "$size" -eq 10000 ]; then
            echo_info "Skipping Matrix Multiplication for size 10000..."
            continue
        fi
        
        matrix1="Matrix_Multiplication/matrix1_${size}.txt"
        matrix2="Matrix_Multiplication/matrix2_${size}.txt"
        output_par="output_${size}_par.txt"
        output_seq="output_${size}_seq.txt"
        output_rs_par="output_${size}_rs_par.txt"
        output_rs_seq="output_${size}_rs_seq.txt"

        # C++ Parallel
        run_cpp_matrix_parallel "Matrix_Multiplication" "MatrixMultiply_omp_par" "$matrix1" "$matrix2" "$output_par" "$THREADS"
        # C++ Sequential
        run_cpp_matrix_sequential "Matrix_Multiplication" "MatrixMultiply_cpp_seq" "$matrix1" "$matrix2" "$output_seq"
        # Rust Parallel
        run_rust_matrix_parallel "Matrix_Multiplication" "MatrixMultiply_rs_par" "$matrix1" "$matrix2" "$output_rs_par" "$THREADS"
        # Rust Sequential
        run_rust_matrix_sequential "Matrix_Multiplication" "MatrixMultiply_rs_seq" "$matrix1" "$matrix2" "$output_rs_seq"
    done
done

# Function to extract time from result files with expanded patterns
get_file_path() {
    local algorithm=$1
    local lang=$2
    local type=$3
    local size=$4
    local threads=$5
    local base_dir="$RESULTS_DIR"

    case "$algorithm" in
        "Matrix_Multiplication")
            echo "${base_dir}/${algorithm}_${lang}_${type}_matrix1_${size}.txt_threads${threads}.txt"
            ;;
        "kmeans")
            echo "${base_dir}/${algorithm}_${lang}_${type}_input_${size}_threads${threads}.txt"
            ;;
        *)
            echo "${base_dir}/${algorithm}_${lang}_${type}_${size}_threads${threads}.txt"
            ;;
    esac
}

debug_extraction() {
    local file=$1
    local extracted_time=$2
    if [[ "$DEBUG" == "true" ]]; then
        echo "Processing file: $file" >&2
        echo "File contents:" >&2
        cat "$file" >&2
        echo "Extracted time: $extracted_time" >&2
        echo "-------------------" >&2
    fi
}

convert_to_microseconds() {
    local value=$1
    local unit=$2
    case "$unit" in
        "s"|"seconds") echo "$value * 1000000" | bc -l ;;
        "ms"|"milliseconds") echo "$value * 1000" | bc -l ;;
        "µs"|"microseconds") echo "$value" | bc -l ;;
        *) echo "Error: Unknown time unit $unit" >&2; echo "0" ;;
    esac
}

convert_scientific_notation() {
    local value=$1
    echo "$value" | awk '{printf "%.9f", $1}'
}
extract_time() {
    local file=$1
    if [[ -f "$file" ]]; then
        # Read the first (and only) line from the file
        local time_value
        read -r time_value < "$file"
        
        # Check if the value is a valid number
        if [[ "$time_value" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            # Return the value in microseconds
            echo "scale=3; $time_value" | bc -l
        else
            if [[ "$DEBUG" == "true" ]]; then
                echo "Invalid time value in file $file: $time_value" >&2
            fi
            echo "0"
        fi
    else
        if [[ "$DEBUG" == "true" ]]; then
            echo "File not found: $file" >&2
        fi
        echo "0"
    fi
}



# Function to get correct result file paths
get_result_file() {
    local algorithm=$1
    local impl_type=$2
    local size=$3
    local threads=$4
    local results_dir=$RESULTS_DIR

    case "$algorithm" in
        "Matrix_Multiplication")
            case "$impl_type" in
                "cpp_seq")
                    echo "${results_dir}/Matrix_Multiplication_cpp_MatrixMultiply_cpp_seq_matrix1_${size}.txt_threads1.txt"
                    ;;
                "cpp_par")
                    echo "${results_dir}/Matrix_Multiplication_cpp_MatrixMultiply_omp_par_matrix1_${size}.txt_threads${threads}.txt"
                    ;;
                "rust_seq")
                    echo "${results_dir}/Matrix_Multiplication_rust_MatrixMultiply_rs_seq_matrix1_${size}.txt_threads1.txt"
                    ;;
                "rust_par")
                    echo "${results_dir}/Matrix_Multiplication_rust_MatrixMultiply_rs_par_matrix1_${size}.txt_threads${threads}.txt"
                    ;;
            esac
            ;;
        "kmeans")
            case "$impl_type" in
                "cpp_seq")
                    echo "${results_dir}/kmeans_cpp_kmeans_cpp_seq_input_${size}_threads1.txt"
                    ;;
                "cpp_par")
                    echo "${results_dir}/kmeans_cpp_kmeans_omp_par_input_${size}_threads${threads}.txt"
                    ;;
                "rust_seq")
                    echo "${results_dir}/kmeans_rust_kmeans_rs_seq_seq_input_${size}_threads1.txt"
                    ;;
                "rust_par")
                    echo "${results_dir}/kmeans_rust_kmeans_rs_par_par_input_${size}_threads${threads}.txt"
                    ;;
            esac
            ;;
        "Dijkstra")
            case "$impl_type" in
                "cpp_seq")
                    echo "${results_dir}/Dijkstra_cpp_dijkstra_seq_${size}_threads1.txt"
                    ;;
                "cpp_par")
                    echo "${results_dir}/Dijkstra_cpp_dijkstra_par_${size}_threads${threads}.txt"
                    ;;
                "rust_seq")
                    echo "${results_dir}/Dijkstra_rust_dijkstra_seq_${size}_threads1.txt"
                    ;;
                "rust_par")
                    echo "${results_dir}/Dijkstra_rust_dijkstra_par_${size}_threads${threads}.txt"
                    ;;
            esac
            ;;
        "MonteCarlo")
            case "$impl_type" in
                "cpp_seq")
                    echo "${results_dir}/MonteCarlo_cpp_monte_carlo_seq_${size}_threads1.txt"
                    ;;
                "cpp_par")
                    echo "${results_dir}/MonteCarlo_cpp_monte_carlo_par_${size}_threads${threads}.txt"
                    ;;
                "rust_seq")
                    echo "${results_dir}/MonteCarlo_rust_monte_carlo_seq_${size}_threads1.txt"
                    ;;
                "rust_par")
                    echo "${results_dir}/MonteCarlo_rust_monte_carlo_par_${size}_threads${threads}.txt"
                    ;;
            esac
            ;;
    esac
}

# Updated function to print results table
print_algorithm_section() {
    local title=$1
    local sizes=("${!2}")
    local algorithm=$3

    echo "$title"
    echo "----------------------------------------"

    for size in "${sizes[@]}"; do
        echo "Problem Size: $size"
        echo "Threads | C++ Seq (ms) | C++ Par (ms) | Rust Seq (ms) | Rust Par (ms) | C++ Speedup | Rust Speedup"
        echo "--------|--------------|--------------|---------------|---------------|-------------|-------------"

        # Get sequential times
        local cpp_seq_file=$(get_result_file "$algorithm" "cpp_seq" "$size" "1")
        local rust_seq_file=$(get_result_file "$algorithm" "rust_seq" "$size" "1")
        
        local cpp_seq_time=$(extract_time "$cpp_seq_file")
        local rust_seq_time=$(extract_time "$rust_seq_file")

        if [[ "$DEBUG" == "true" ]]; then
            echo "Sequential file paths:"
            echo "C++: $cpp_seq_file"
            echo "Rust: $rust_seq_file"
            echo "Times extracted:"
            echo "C++ Sequential: $cpp_seq_time"
            echo "Rust Sequential: $rust_seq_time"
        fi

        # For each thread configuration
        for threads in "${THREAD_CONFIGS[@]}"; do
            local cpp_par_file=$(get_result_file "$algorithm" "cpp_par" "$size" "$threads")
            local rust_par_file=$(get_result_file "$algorithm" "rust_par" "$size" "$threads")
            
            local cpp_par_time=$(extract_time "$cpp_par_file")
            local rust_par_time=$(extract_time "$rust_par_file")

            if [[ "$DEBUG" == "true" ]]; then
                echo "Thread $threads parallel file paths:"
                echo "C++: $cpp_par_file"
                echo "Rust: $rust_par_file"
                echo "Times extracted:"
                echo "C++ Parallel: $cpp_par_time"
                echo "Rust Parallel: $rust_par_time"
            fi

            # Calculate speedups
            local cpp_speedup=$(calculate_speedup "$cpp_seq_time" "$cpp_par_time")
            local rust_speedup=$(calculate_speedup "$rust_seq_time" "$rust_par_time")

            printf "%-8s | %12.3f | %12.3f | %13.3f | %13.3f | %11.2f | %11.2f\n" \
                "$threads" "$cpp_seq_time" "$cpp_par_time" "$rust_seq_time" "$rust_par_time" "$cpp_speedup" "$rust_speedup"
        done
        echo ""
    done
    echo ""
}

# Helper function to calculate speedup
calculate_speedup() {
    local seq_time=$1
    local par_time=$2
    
    if [[ -n "$seq_time" && -n "$par_time" && "$par_time" != "0" && "$seq_time" != "0" ]]; then
        # Use bc for floating point arithmetic with high precision
        printf "%.2f" $(echo "scale=6; $seq_time/$par_time" | bc -l)
    else
        echo "0.00"
    fi
}
# Create performance comparison report
PERFORMANCE_FILE="${RESULTS_DIR}/performance_comparison_threads.txt"
{
    echo "Performance Comparison: Rust vs C++ with Multiple Thread Configurations"
    echo "=================================================================="
    echo "Date: $(date)"
    echo ""

    print_algorithm_section "1. Dijkstra's Algorithm" Dijkstra_SIZES[@] "Dijkstra"
    print_algorithm_section "2. Matrix Multiplication" Matrix_Multiplication_SIZES[@] "Matrix_Multiplication"
    print_algorithm_section "3. K-Means Clustering" KMeans_SIZES[@] "kmeans"
    print_algorithm_section "4. Monte Carlo" MC_SIZES[@] "MonteCarlo"

    echo "Notes:"
    echo "- All times are in microseconds (ms)"
    echo "- Speedup = Sequential Time / Parallel Time"
    echo "- Tests conducted with thread counts: ${THREAD_CONFIGS[*]}"
    echo "- Sequential times are shown for reference and are the same across all thread configurations"
} > "$PERFORMANCE_FILE"

echo_info "Performance comparison has been written to: $PERFORMANCE_FILE"
echo_info "All experiments completed successfully!"
