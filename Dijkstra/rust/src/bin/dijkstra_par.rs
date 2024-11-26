use std::env;
use rand::Rng;
use rayon::prelude::*;
use std::time::Instant;

/// Finds the vertex with the minimum distance value from the set of vertices not yet processed.
/// Utilizes Rayon’s parallel iterators for efficient computation.
fn min_distance(distances: &Vec<i32>, visited: &Vec<bool>) -> Option<usize> {
    distances.par_iter()
        .enumerate()
        .filter(|(i, _)| !visited[*i])
        .min_by_key(|&(_, dist)| dist)
        .map(|(i, _)| i)
}

/// Dijkstra's algorithm to find the shortest path from a start vertex.
/// Optimized to leverage Rayon for parallel computation of distance updates.
fn dijkstra(graph: &Vec<Vec<Option<usize>>>, start: usize, size: usize) -> Vec<i32> {
    // Initialize distances as infinity and visited as false for all vertices
    let mut distances = vec![i32::MAX; size];
    let mut visited = vec![false; size];

    distances[start] = 0; // Distance to the start vertex is 0

    for _ in 0..size - 1 {
        // Select the unvisited vertex with the smallest distance
        let u = match min_distance(&distances, &visited) {
            Some(u) => u,
            None => break, // All reachable vertices have been processed
        };

        if distances[u] == i32::MAX {
            break; // Remaining vertices are inaccessible from the source
        }

        visited[u] = true; // Mark the vertex as visited

        // Collect potential distance updates in parallel
        let new_distances: Vec<(usize, i32)> = graph[u].par_iter()
            .enumerate()
            .filter_map(|(v, &weight)| {
                if let Some(w) = weight {
                    if !visited[v] && distances[u] != i32::MAX {
                        let next_distance = distances[u] + w as i32;
                        if next_distance < distances[v] {
                            Some((v, next_distance))
                        } else {
                            None
                        }
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
            .collect();

        // Apply the collected distance updates
        for (v, dist) in new_distances {
            distances[v] = dist;
        }
    }

    distances
}

/// Generates a random adjacency matrix for an undirected graph.
/// Each edge has a 70% chance of existing with a random weight between 1 and `max_weight`.
fn generate_graph(num_vertices: usize, max_weight: usize) -> Vec<Vec<Option<usize>>> {
    let mut rng = rand::thread_rng();
    let mut graph: Vec<Vec<Option<usize>>> = vec![vec![None; num_vertices]; num_vertices];

    for i in 0..num_vertices {
        for j in 0..num_vertices {
            if i != j && rng.gen_bool(0.7) {
                graph[i][j] = Some(rng.gen_range(1..=max_weight));
            }
        }
    }

    graph
}

fn main() {
    // Parse command-line arguments
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 || args.len() > 3 {
        eprintln!("Usage: {} <graph_size> [num_threads]", args[0]);
        std::process::exit(1);
    }

    // Parse the graph size
    let size: usize = match args[1].parse() {
        Ok(n) if n > 0 => n,
        _ => {
            eprintln!("Error: <graph_size> must be a positive integer.");
            std::process::exit(1);
        }
    };

    // Optionally parse the number of threads (currently unused as Rayon manages the thread pool)
    if args.len() == 3 {
        let num_threads: usize = match args[2].parse() {
            Ok(n) if n > 0 => n,
            _ => {
                eprintln!("Error: [num_threads] must be a positive integer.");
                std::process::exit(1);
            }
        };
        rayon::ThreadPoolBuilder::new()
            .num_threads(num_threads)
            .build_global()
            .unwrap_or_else(|_| {
                eprintln!("Error: Failed to build the Rayon thread pool.");
                std::process::exit(1);
            });
    }

    let max_weight = 20;
    let start_vertex = 0;

    // Generate a random graph
    let graph = generate_graph(size, max_weight);

    // Uncomment the following lines to print the generated graph
    /*
    println!("Generated Graph (Adjacency Matrix):");
    for row in &graph {
        for &weight in row {
            match weight {
                Some(w) => print!("{:3} ", w),
                None => print!("  . "),
            }
        }
        println!();
    }
    */

    println!(
        "Running parallel Dijkstra's algorithm with graph size {}x{} using Rayon...",
        size, size
    );

    // Start timing
    let start = Instant::now();

    // Execute Dijkstra's algorithm
    let distances = dijkstra(&graph, start_vertex, size);

    // End timing
    let duration = start.elapsed();
    println!("Time taken for parallel Dijkstra in Rust for size {1} by {1}: {0:?}", duration, size);
    

    // Uncomment the following lines to print the shortest distances
    /*
    println!("\nShortest distances from vertex {}:", start_vertex);
    for (i, &dist) in distances.iter().enumerate() {
        println!(
            "Vertex {}: {}",
            i,
            if dist == i32::MAX {
                "∞".to_string()
            } else {
                dist.to_string()
            }
        );
    }
    */
}
