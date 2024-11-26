#!/bin/bash

# run_all.sh
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
PROBLEM_SIZES=(10 100 )
Dijkstra_SIZES=(10 100 )
MC_SIZES=(10 100 )
KMeans_SIZES=(10 100 )
Matrix_Multiplication_SIZES=(10 100 )

# Define number of clusters for KMeans
KMEANS_CLUSTERS=10
THREAD_CONFIGS=(2 4 8 16 32)

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

    echo_info "Input generation executables compiled successfully."
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

    # Check if Cargo.toml exists
    CARGO_TOML_PATH="$PROJECT_DIR/rust/Cargo.toml"
    if [[ -f "$CARGO_TOML_PATH" ]]; then
        cargo build --release --manifest-path "$CARGO_TOML_PATH" --bin "$BIN_NAME"
        echo_info "Compiled Rust binary $BIN_NAME successfully."
    else
        echo_error "Cargo.toml not found in $PROJECT_DIR/rust/. Please ensure the Rust project is set up correctly."
        exit 1
    fi
}

# Function to generate matrices in parallel if they do not exist
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

# Function to generate K-Means inputs if they do not exist
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
            echo "$size" | ./generate_kmeans_input "$size"
        )
    fi
}

run_cpp_dijkstra() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${SIZE}_threads${THREADS}.txt"

    if [[ "$EXECUTABLE" == "dijkstra_par" ]]; then
        echo_info "Running C++ $EXECUTABLE with size $SIZE and threads $THREADS..."
        OMP_NUM_THREADS=$THREADS ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" > "$output_file"
    else
        echo_info "Running C++ $EXECUTABLE with size $SIZE (sequential)..."
        ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" > "$output_file"
    fi
}

run_rust_dijkstra() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${SIZE}_threads${THREADS}.txt"

    if [[ "$BIN_NAME" == "dijkstra_par" ]]; then
        echo_info "Running Rust $BIN_NAME with size $SIZE and threads $THREADS..."
        RAYON_NUM_THREADS=$THREADS ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" > "$output_file"
    else
        echo_info "Running Rust $BIN_NAME with size $SIZE (sequential)..."
        ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" > "$output_file"
    fi
}

run_cpp_monte_carlo() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${SIZE}_threads${THREADS}.txt"

    if [[ "$EXECUTABLE" == "monte_carlo_par" ]]; then
        echo_info "Running C++ $EXECUTABLE with size $SIZE and threads $THREADS..."
        OMP_NUM_THREADS=$THREADS ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" > "$output_file"
    else
        echo_info "Running C++ $EXECUTABLE with size $SIZE (sequential)..."
        ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$SIZE" > "$output_file"
    fi
}

run_rust_monte_carlo() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    SIZE=$3
    THREADS=$4

    output_file="${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${SIZE}_threads${THREADS}.txt"

    if [[ "$BIN_NAME" == "monte_carlo_par" ]]; then
        echo_info "Running Rust $BIN_NAME with size $SIZE and threads $THREADS..."
        RAYON_NUM_THREADS=$THREADS ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" > "$output_file"
    else
        echo_info "Running Rust $BIN_NAME with size $SIZE (sequential)..."
        ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$SIZE" > "$output_file"
    fi
}

run_cpp_kmeans() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5
    THREADS=$6

    if [[ "$EXECUTABLE" == "kmeans_omp_par" ]]; then
        echo_info "Running C++ $EXECUTABLE with input $INPUT_FILE, clusters $CLUSTERS, and threads $THREADS..."
        OMP_NUM_THREADS=$THREADS ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" > "${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$INPUT_FILE" .txt)_threads${THREADS}.txt"
    else
        echo_info "Running C++ $EXECUTABLE with input $INPUT_FILE, clusters $CLUSTERS (sequential)..."
        ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" > "${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_$(basename "$INPUT_FILE" .txt).txt"
    fi
}

run_rust_kmeans() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    INPUT_FILE=$3
    OUTPUT_FILE=$4
    CLUSTERS=$5
    MODE=$6
    THREADS=$7

    if [[ "$MODE" == "par" ]]; then
        echo_info "Running Rust $BIN_NAME in $MODE mode with input $INPUT_FILE, clusters $CLUSTERS, and threads $THREADS..."
        RAYON_NUM_THREADS=$THREADS ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" "$THREADS" > "${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${MODE}_$(basename "$INPUT_FILE" .txt)_threads${THREADS}.txt"
    else
        echo_info "Running Rust $BIN_NAME in $MODE mode with input $INPUT_FILE, clusters $CLUSTERS (sequential)..."
        ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$INPUT_FILE" "$OUTPUT_FILE" "$CLUSTERS" "1" > "${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${MODE}_$(basename "$INPUT_FILE" .txt).txt"
    fi
}

run_cpp_matrix_multiplication() {
    PROJECT_DIR=$1
    EXECUTABLE=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5
    THREADS=$6

    matrix_results_dir="$PROJECT_DIR/results"
    mkdir -p "$matrix_results_dir"
    actual_output="$matrix_results_dir/${OUTPUT_FILE}"

    # Strip the .txt extension from MATRIX1 for consistent naming
    MATRIX1_BASE=$(basename "$MATRIX1" .txt)

    echo_info "Running C++ $EXECUTABLE with matrices $MATRIX1 and $MATRIX2 and threads $THREADS..."
    if [[ "$EXECUTABLE" == "MatrixMultiply_omp_par" ]]; then
        OMP_NUM_THREADS=$THREADS ./"$PROJECT_DIR/cpp/$EXECUTABLE" "$MATRIX1" "$MATRIX2" "$actual_output" "$THREADS" > "${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${MATRIX1_BASE}_threads${THREADS}.txt" 2>&1
    else
        ./"$PROJECT_DIR/cpp/MatrixMultiply_cpp_seq" "$MATRIX1" "$MATRIX2" "$actual_output" > "${RESULTS_DIR}/${PROJECT_DIR}_cpp_${EXECUTABLE}_${MATRIX1_BASE}.txt" 2>&1
    fi
}


run_rust_matrix_multiplication() {
    PROJECT_DIR=$1
    BIN_NAME=$2
    MATRIX1=$3
    MATRIX2=$4
    OUTPUT_FILE=$5
    THREADS=$6

    matrix_results_dir="$PROJECT_DIR/results"
    mkdir -p "$matrix_results_dir"
    actual_output="$matrix_results_dir/${OUTPUT_FILE}"

    # Strip the .txt extension from MATRIX1 for consistent naming
    MATRIX1_BASE=$(basename "$MATRIX1" .txt)

    echo_info "Running Rust $BIN_NAME with matrices $MATRIX1 and $MATRIX2 and threads $THREADS..."
    if [[ "$BIN_NAME" == "MatrixMultiply_rs_par" ]]; then
        RAYON_NUM_THREADS=$THREADS ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$MATRIX1" "$MATRIX2" "$actual_output" "$THREADS" > "${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${MATRIX1_BASE}_threads${THREADS}.txt" 2>&1
    else
        ./"$PROJECT_DIR/rust/target/release/$BIN_NAME" "$MATRIX1" "$MATRIX2" "$actual_output" > "${RESULTS_DIR}/${PROJECT_DIR}_rust_${BIN_NAME}_${MATRIX1_BASE}.txt" 2>&1
    fi
}


# Compile Input Generators
compile_input_generators

# Generate all input files
echo_info "Generating all input files..."

# 1. Generate Matrix Multiplication Inputs
echo_info "Generating Matrix Multiplication inputs..."
for size in "${Matrix_Multiplication_SIZES[@]}"; do
    generate_matrix_if_not_exists "$size"
done

# 2. Generate K-Means Inputs
echo_info "Generating K-Means inputs..."
for size in "${KMeans_SIZES[@]}"; do
    generate_kmeans_if_not_exists "$size"
done

echo_info "Input generation completed."

# Compile all C++ projects
echo_info "Compiling all C++ projects..."

# Compile Dijkstra C++ Parallel and Sequential
compile_cpp "Dijkstra" "dijkstra_par" "dijkstra_par.cpp" "dijkstra_seq" "dijkstra_seq.cpp"

# Compile Matrix Multiplication C++ Parallel and Sequential
compile_cpp "Matrix_Multiplication" "MatrixMultiply_omp_par" "MatrixMultiply_omp_par.cpp" "MatrixMultiply_cpp_seq" "MatrixMultiply_cpp_seq.cpp"

# Compile K-Means C++ Parallel and Sequential
compile_cpp "kmeans" "kmeans_omp_par" "kmeans_omp_par.cpp" "kmeans_cpp_seq" "kmeans_cpp_seq.cpp"

# Compile Monte Carlo C++ Parallel and Sequential
compile_cpp "MonteCarlo" "monte_carlo_par" "monte_carlo_omp_par.cpp" "monte_carlo_seq" "monte_carlo_cpp_seq.cpp"

echo_info "C++ compilation completed."

# Compile all Rust projects
echo_info "Compiling all Rust projects..."

# Compile Dijkstra Rust Parallel and Sequential
compile_rust "Dijkstra" "dijkstra_par"
compile_rust "Dijkstra" "dijkstra_seq"

# Compile Matrix Multiplication Rust Parallel and Sequential
compile_rust "Matrix_Multiplication" "MatrixMultiply_rs_par"
compile_rust "Matrix_Multiplication" "MatrixMultiply_rs_seq"

# Compile K-Means Rust Parallel and Sequential
compile_rust "kmeans" "kmeans_rs_par"
compile_rust "kmeans" "kmeans_rs_seq"

# Compile Monte Carlo Rust Parallel and Sequential
compile_rust "MonteCarlo" "monte_carlo_par"
compile_rust "MonteCarlo" "monte_carlo_seq"

echo_info "Rust compilation completed."

# Run all executables and collect results
echo_info "Running all executables and collecting results..."

# Ensure executables have execute permissions
chmod +x Dijkstra/cpp/dijkstra_par
chmod +x Dijkstra/cpp/dijkstra_seq
chmod +x Matrix_Multiplication/cpp/MatrixMultiply_omp_par
chmod +x Matrix_Multiplication/cpp/MatrixMultiply_cpp_seq
chmod +x kmeans/cpp/kmeans_omp_par
chmod +x kmeans/cpp/kmeans_cpp_seq
chmod +x MonteCarlo/cpp/monte_carlo_par
chmod +x MonteCarlo/cpp/monte_carlo_seq

# Run sequential versions once
echo_info "Running sequential versions..."

# Dijkstra Sequential
for size in "${Dijkstra_SIZES[@]}"; do
    run_cpp_dijkstra "Dijkstra" "dijkstra_seq" "$size" "1"
    run_rust_dijkstra "Dijkstra" "dijkstra_seq" "$size" "1"
done

# Monte Carlo Sequential
for size in "${MC_SIZES[@]}"; do
    run_cpp_monte_carlo "MonteCarlo" "monte_carlo_seq" "$size" "1"
    run_rust_monte_carlo "MonteCarlo" "monte_carlo_seq" "$size" "1"
done

# K-Means Sequential
for size in "${KMeans_SIZES[@]}"; do
    input_file="kmeans/input_${size}.txt"
    output_cpp_seq="kmeans/out${size}_cpp_seq.txt"
    output_rs_seq="kmeans/out${size}_rs_seq.txt"

    run_cpp_kmeans "kmeans" "kmeans_cpp_seq" "$input_file" "$output_cpp_seq" "$KMEANS_CLUSTERS" "1"
    run_rust_kmeans "kmeans" "kmeans_rs_seq" "$input_file" "$output_rs_seq" "$KMEANS_CLUSTERS" "seq" "1"
done

# Matrix Multiplication Sequential
for size in "${Matrix_Multiplication_SIZES[@]}"; do
    matrix1="Matrix_Multiplication/matrix1_${size}.txt"
    matrix2="Matrix_Multiplication/matrix2_${size}.txt"
    output_seq="output_${size}_seq.txt"
    output_rs_seq="output_${size}_rs_seq.txt"

    run_cpp_matrix_multiplication "Matrix_Multiplication" "MatrixMultiply_cpp_seq" "$matrix1" "$matrix2" "$output_seq" "1"
    run_rust_matrix_multiplication "Matrix_Multiplication" "MatrixMultiply_rs_seq" "$matrix1" "$matrix2" "$output_rs_seq" "1"
done

# Run parallel versions with different thread configurations
for THREADS in "${THREAD_CONFIGS[@]}"; do
    echo_info "Running parallel versions with $THREADS threads..."
    
    # Dijkstra Parallel
    for size in "${Dijkstra_SIZES[@]}"; do
        run_cpp_dijkstra "Dijkstra" "dijkstra_par" "$size" "$THREADS"
        run_rust_dijkstra "Dijkstra" "dijkstra_par" "$size" "$THREADS"
    done

    # Monte Carlo Parallel
    for size in "${MC_SIZES[@]}"; do
        run_cpp_monte_carlo "MonteCarlo" "monte_carlo_par" "$size" "$THREADS"
        run_rust_monte_carlo "MonteCarlo" "monte_carlo_par" "$size" "$THREADS"
    done

    # K-Means Parallel
    for size in "${KMeans_SIZES[@]}"; do
        input_file="kmeans/input_${size}.txt"
        output_cpp_par="kmeans/out${size}_omp_par.txt"
        output_rs_par="kmeans/out${size}_rs_par.txt"

        run_cpp_kmeans "kmeans" "kmeans_omp_par" "$input_file" "$output_cpp_par" "$KMEANS_CLUSTERS" "$THREADS"
        run_rust_kmeans "kmeans" "kmeans_rs_par" "$input_file" "$output_rs_par" "$KMEANS_CLUSTERS" "par" "$THREADS"
    done

    # Matrix Multiplication Parallel
    for size in "${Matrix_Multiplication_SIZES[@]}"; do
        matrix1="Matrix_Multiplication/matrix1_${size}.txt"
        matrix2="Matrix_Multiplication/matrix2_${size}.txt"
        output_par="output_${size}_par.txt"
        output_rs_par="output_${size}_rs_par.txt"

        run_cpp_matrix_multiplication "Matrix_Multiplication" "MatrixMultiply_omp_par" "$matrix1" "$matrix2" "$output_par" "$THREADS"
        run_rust_matrix_multiplication "Matrix_Multiplication" "MatrixMultiply_rs_par" "$matrix1" "$matrix2" "$output_rs_par" "$THREADS"
    done
done


echo_info "Creating results summary..."
SUMMARY_FILE="${RESULTS_DIR}/summary.txt"
PERFORMANCE_FILE="${RESULTS_DIR}/performance_comparison.txt"

# Improved time extraction function with debugging
# Function to extract time from result files with expanded patterns
extract_time() {
    local file=$1
    if [[ -f "$file" ]]; then
        # Debug output
        echo "Processing file: $file" >&2
        
        # Matrix multiplication format
        if grep -q "Matrix multiplication took" "$file"; then
            grep "Matrix multiplication took" "$file" | grep -o "[0-9.]*" | head -n1
            return
        fi
        
        # Elapsed microseconds format
        if grep -q "Elapsed microseconds = " "$file"; then
            grep "Elapsed microseconds = " "$file" | awk '{print $4}'
            return
        fi
        
        # Dijkstra format with microseconds
        if grep -q "Time taken for.*Dijkstra.*microseconds" "$file"; then
            # Extract only the number before "microseconds"
            grep "Time taken for.*Dijkstra.*: " "$file" | sed 's/.*: \([0-9.]*\) microseconds.*/\1/'
            return
        fi
        
        # Dijkstra format with µs
        if grep -q "Time taken for.*Dijkstra.*µs" "$file"; then
            # Extract only the number before "µs"
            grep "Time taken for.*: " "$file" | sed 's/.*: \([0-9.]*\)µs.*/\1/'
            return
        fi
        
        # K-means microseconds format
        if grep -q "Time taken = " "$file"; then
            grep "Time taken = " "$file" | awk '{print $4}'
            return
        fi
        
        # K-means "completed in" format
        if grep -q "completed in" "$file"; then
            grep "completed in" "$file" | grep -o "[0-9]* microseconds" | grep -o "[0-9]*"
            return
        fi
        
        # Monte Carlo format (scientific notation)
        if grep -q "Time taken: " "$file"; then
            # Extract time in seconds and convert to microseconds
            time_str=$(grep "Time taken: " "$file" | sed 's/.*: \([0-9.e+-]*\) seconds.*/\1/')
            if [[ -n "$time_str" ]]; then
                # Convert scientific notation to microseconds using awk
                echo "$time_str" | awk '{printf "%.0f", $1 * 1000000}'
                return
            fi
        fi
        
        # Debug output for unmatched patterns
        echo "No matching time pattern found in file: $file" >&2
        cat "$file" >&2
        echo "0"
    else
        echo "File not found: $file" >&2
        echo "0"
    fi
}

# Helper function to calculate speedup with validation
calculate_speedup() {
    local seq=$1
    local par=$2
    
    # Ensure both values exist and par is not 0
    if [[ -n "$seq" && -n "$par" && "$par" != "0" ]]; then
        # If sequential time is less than 1 microsecond, use a minimum of 1
        if (( $(echo "$seq < 1" | bc -l) )); then
            seq=1
        fi
        # Calculate speedup with 2 decimal places
        printf "%.2f" $(echo "scale=2; $seq/$par" | bc -l 2>/dev/null || echo "0")
    else
        echo "0.00"
    fi
}

# Function to print algorithm section with correct timing extraction


print_algorithm_section() {
    local title=$1
    local sizes=("${!2}")
    local base_name=$3
    
    echo "$title"
    echo "----------------------------------------"
    
    for size in "${sizes[@]}"; do
        echo "Problem Size: $size"
        echo "Threads | C++ Seq (µs) | C++ Par (µs) | Rust Seq (µs) | Rust Par (µs) | C++ Speedup | Rust Speedup"
        echo "--------|--------------|--------------|---------------|---------------|-------------|-------------"
        
        # Get sequential times (only need to do this once per size)
        case $base_name in
            "dijkstra")
                cpp_seq_file="${RESULTS_DIR}/Dijkstra_cpp_dijkstra_seq_${size}_threads1.txt"
                rust_seq_file="${RESULTS_DIR}/Dijkstra_rust_dijkstra_seq_${size}_threads1.txt"
                ;;
            "MatrixMultiply")
                cpp_seq_file="${RESULTS_DIR}/Matrix_Multiplication_cpp_MatrixMultiply_cpp_seq_matrix1_${size}"
                rust_seq_file="${RESULTS_DIR}/Matrix_Multiplication_rust_MatrixMultiply_rs_seq_matrix1_${size}"
                ;;
            "kmeans")
                cpp_seq_file="${RESULTS_DIR}/kmeans_cpp_kmeans_cpp_seq_input_${size}.txt"
                rust_seq_file="${RESULTS_DIR}/kmeans_rust_kmeans_rs_seq_seq_input_${size}.txt"
                ;;
            "monte_carlo")
                cpp_seq_file="${RESULTS_DIR}/MonteCarlo_cpp_monte_carlo_seq_${size}_threads1.txt"
                rust_seq_file="${RESULTS_DIR}/MonteCarlo_rust_monte_carlo_seq_${size}_threads1.txt"
                ;;
        esac

        cpp_seq=$(extract_time "$cpp_seq_file")
        rust_seq=$(extract_time "$rust_seq_file")
        
        # Print results for each thread configuration
        for threads in "${THREAD_CONFIGS[@]}"; do
            case $base_name in
                "dijkstra")
                    cpp_par_file="${RESULTS_DIR}/Dijkstra_cpp_dijkstra_par_${size}_threads${threads}.txt"
                    rust_par_file="${RESULTS_DIR}/Dijkstra_rust_dijkstra_par_${size}_threads${threads}.txt"
                    ;;
                "MatrixMultiply")
                    cpp_par_file="${RESULTS_DIR}/Matrix_Multiplication_cpp_MatrixMultiply_omp_par_matrix1_${size}_threads${threads}"
                    rust_par_file="${RESULTS_DIR}/Matrix_Multiplication_rust_MatrixMultiply_rs_par_matrix1_${size}_threads${threads}"
                    ;;
                "kmeans")
                    cpp_par_file="${RESULTS_DIR}/kmeans_cpp_kmeans_omp_par_input_${size}_threads${threads}.txt"
                    rust_par_file="${RESULTS_DIR}/kmeans_rust_kmeans_rs_par_par_input_${size}_threads${threads}.txt"
                    ;;
                "monte_carlo")
                    cpp_par_file="${RESULTS_DIR}/MonteCarlo_cpp_monte_carlo_par_${size}_threads${threads}.txt"
                    rust_par_file="${RESULTS_DIR}/MonteCarlo_rust_monte_carlo_par_${size}_threads${threads}.txt"
                    ;;
            esac
            
            cpp_par=$(extract_time "$cpp_par_file")
            rust_par=$(extract_time "$rust_par_file")
            
            cpp_speedup=$(calculate_speedup "$cpp_seq" "$cpp_par")
            rust_speedup=$(calculate_speedup "$rust_seq" "$rust_par")
            
            printf "%-8s | %-12s | %-12s | %-13s | %-13s | %-11s | %-11s\n" \
                "$threads" "$cpp_seq" "$cpp_par" "$rust_seq" "$rust_par" "$cpp_speedup" "$rust_speedup"
        done
        echo ""
    done
    echo ""
}


# Create temporary debug log
DEBUG_LOG="${RESULTS_DIR}/debug.log"
echo "Debug Log for Performance Extraction" > "$DEBUG_LOG"
echo "Timestamp: $(date)" >> "$DEBUG_LOG"
echo "----------------------------------------" >> "$DEBUG_LOG"

# Modified performance comparison section with debugging
{
    echo "Performance Comparison: Rust vs C++ with Multiple Thread Configurations"
    echo "=================================================================="
    echo "Date: $(date)"
    echo ""
    
    print_algorithm_section "1. Dijkstra's Algorithm" Dijkstra_SIZES[@] "dijkstra" 2>> "$DEBUG_LOG"
    print_algorithm_section "2. Matrix Multiplication" Matrix_Multiplication_SIZES[@] "MatrixMultiply" 2>> "$DEBUG_LOG"
    print_algorithm_section "3. K-Means Clustering" KMeans_SIZES[@] "kmeans" 2>> "$DEBUG_LOG"
    print_algorithm_section "4. Monte Carlo" MC_SIZES[@] "monte_carlo" 2>> "$DEBUG_LOG"
    
    echo "Notes:"
    echo "- All times are in microseconds (µs)"
    echo "- Speedup = Sequential Time / Parallel Time"
    echo "- Tests conducted with thread counts: ${THREAD_CONFIGS[*]}"
    echo "- Sequential times are shown for reference and are the same across all thread configurations"
} > "$PERFORMANCE_FILE"

echo_info "Performance comparison has been written to: $PERFORMANCE_FILE"
echo_info "Debug information written to: $DEBUG_LOG"