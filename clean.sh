#!/bin/bash

# clean_builds.sh
# A script to clean all Rust build artifacts and C++ executables across multiple projects.

# Exit immediately if a command exits with a non-zero status
set -e

# Debug and configuration flags
DEBUG=false

# Function to display informational messages
function echo_info {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# Function to display error messages
function echo_error {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# Function to display warning messages
function echo_warn {
    echo -e "\033[1;33m[WARN]\033[0m $1"
}

# List of project directories
PROJECTS=("Dijkstra" "Matrix_Multiplication" "kmeans" "MonteCarlo")

# Function to clean C++ executables in a given project
clean_cpp_executables() {
    local project_dir=$1
    local cpp_dir="${project_dir}/cpp"

    if [[ -d "$cpp_dir" ]]; then
        echo_info "Cleaning C++ executables in $cpp_dir..."

        # Find and remove executables (files without extension and with execute permission)
        find "$cpp_dir" -maxdepth 1 -type f \( ! -name "*.cpp" ! -name "*.h" ! -name "*.hpp" ! -name "*.c" ! -name "*.cc" \) -perm /u=x,g=x,o=x -exec rm -f {} +

        if [[ "$DEBUG" == "true" ]]; then
            echo_info "C++ executables in $cpp_dir have been removed."
        fi
    else
        echo_warn "C++ directory $cpp_dir does not exist. Skipping."
    fi
}

# Function to clean Rust build artifacts in a given project
clean_rust_build() {
    local project_dir=$1
    local rust_dir="${project_dir}/rust"

    if [[ -d "$rust_dir" ]]; then
        echo_info "Cleaning Rust build artifacts in $rust_dir..."

        # Check if Cargo.toml exists to confirm it's a Rust project
        if [[ -f "${rust_dir}/Cargo.toml" ]]; then
            (
                cd "$rust_dir"
                cargo clean
            )
            if [[ "$DEBUG" == "true" ]]; then
                echo_info "Rust build artifacts in $rust_dir have been cleaned using 'cargo clean'."
            fi
        else
            echo_warn "Cargo.toml not found in $rust_dir. Skipping Rust clean for this project."
        fi
    else
        echo_warn "Rust directory $rust_dir does not exist. Skipping."
    fi
}

# Function to clean additional build artifacts if necessary
clean_additional_artifacts() {
    local project_dir=$1

    # Example: Remove input generator executables if they exist
    local input_gen_dirs=("Matrix_Multiplication" "kmeans")
    for dir in "${input_gen_dirs[@]}"; do
        local input_dir="${project_dir}/${dir}"
        if [[ -d "$input_dir" ]]; then
            # Assuming input generators are named like generate_matrix_input and generate_kmeans_input
            local executables=("generate_matrix_input" "generate_kmeans_input")
            for exe in "${executables[@]}"; do
                local exe_path="${input_dir}/${exe}"
                if [[ -f "$exe_path" ]]; then
                    echo_info "Removing input generator executable: $exe_path"
                    rm -f "$exe_path"
                fi
            done
        fi
    done
}

# Main cleaning process
echo_info "Starting cleaning process for Rust and C++ build artifacts..."

for project in "${PROJECTS[@]}"; do
    echo_info "Processing project: $project"

    # Clean C++ executables
    clean_cpp_executables "$project"

    # Clean Rust build artifacts
    clean_rust_build "$project"

    # Clean additional build artifacts if necessary
    clean_additional_artifacts "$project"

    echo_info "Finished cleaning project: $project"
    echo ""
done

echo_info "All specified build artifacts have been cleaned successfully!"

# Optionally, remove the results directory if it exists
RESULTS_DIR=$(ls -d results_* 2>/dev/null | head -n 1)
if [[ -n "$RESULTS_DIR" && -d "$RESULTS_DIR" ]]; then
    echo_info "Removing results directory: $RESULTS_DIR"
    rm -rf "$RESULTS_DIR"
    echo_info "Results directory removed."
fi

echo_info "Cleaning process completed."

