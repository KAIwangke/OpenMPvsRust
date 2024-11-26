use std::i32;
use std::env;
use rand::Rng;
use std::time::Instant;


// Finds the vertex with the minimum distance value, from the set of vertices not yet processed
fn min_distance(distances: &Vec<i32>, visited: &Vec<bool>) -> usize {
    let mut min = i32::MAX;
    let mut min_index = 0;

    for (i, &distance) in distances.iter().enumerate() {
        if !visited[i] && distance <= min {
            min = distance;
            min_index = i;
        }
    }
    
    min_index
}

// Dijkstra's algorithm to find the shortest path from a start vertex
fn dijkstra(graph: &Vec<Vec<Option<usize>>>, start: usize, size: usize) -> Vec<i32> {
    let mut distances = vec![i32::MAX; size]; // Initialize distances as infinity
    let mut visited = vec![false; size]; // Track visited vertices

    distances[start] = 0; // Distance to the start vertex is 0

    for _ in 0..size-1 {

        let u = min_distance(&distances, &visited); // Get the unvisited vertex with the minimum distance
        visited[u] = true;

        // Update distance value of the adjacent vertices of the chosen vertex
        for v in 0..size {
            if let Some(weight) = graph[u][v] {
                if !visited[v] && distances[u] != i32::MAX && distances[u] + (weight as i32) < distances[v] {
                    distances[v] = distances[u] + weight as i32;
                }
            }
        }
    }

    distances
}

// Function to generate a random graph
fn generate_graph(size: usize, max_weight: usize) -> Vec<Vec<Option<usize>>> {
    let mut rng = rand::thread_rng();
    let mut graph: Vec<Vec<Option<usize>>> = vec![vec![None; size]; size];

    for i in 0..size {
        for j in 0..size {
            if i != j && rng.gen_range(0..100) < 70 {
                graph[i][j] = Some(rng.gen_range(1..=max_weight));
            }
        }
    }

    graph
}

fn main() {
    // Parse the graph size from the command line arguments
    let args: Vec<String> = env::args().collect();
    let size: usize = args[1].parse().expect("graph size");

    
    // Generate a random graph
    let graph = generate_graph(size, 10);
    
    // Print the generated graph
    // println!("Generated Graph (Adjacency Matrix):");
    // for row in &graph {
    //     for &weight in row {
    //         match weight {
    //             Some(w) => print!("{:3} ", w),
    //             None => print!("  . "),
    //         }
    //     }
    //     println!();
    // }



    // start clock
    let start = Instant::now();

    // Run Dijkstra's algorithm
    let distances = dijkstra(&graph, 0, size);

    // end clock
    let duration = start.elapsed();
    println!("{}", duration.as_micros());






    // Print shortest distances from the start vertex
    // println!("\nShortest distances from vertex {}:", start_vertex);
    // for (i, &dist) in distances.iter().enumerate() {
    //     println!(
    //         "Vertex {}: {}",
    //         i,
    //         if dist == i32::MAX {
    //             "∞".to_string()
    //         } else {
    //             dist.to_string()
    //         }
    //     );
    // }
}
