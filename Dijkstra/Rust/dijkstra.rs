use rand::Rng;
use std::collections::BinaryHeap;
use std::sync::{Arc, Mutex};
use rayon::prelude::*;
use std::usize;



fn dijkstra(graph: &Vec<Vec<Option<usize>>>, start: usize) -> Vec<usize> {
    let n = graph.len();
    let distances = Arc::new(Mutex::new(vec![usize::MAX; n])); // Initialize all distances to infinity
    distances.lock().unwrap()[start] = 0; // Set the distance to the start node to 0

    let mut heap = BinaryHeap::new();
    heap.push((0, start)); // Start with the source node (distance 0, start node)

    while let Some((distance, vertex)) = heap.pop() {
        // Skip outdated entries in the heap
        if distance > distances.lock().unwrap()[vertex] {
            continue;
        }

        // Process each neighbor of the current vertex
        let updates: Vec<(usize, usize)> = graph[vertex]
            .par_iter()
            .enumerate()
            .filter_map(|(neighbor, &weight)| {
                if let Some(weight) = weight {
                    let next_distance = distance + weight;
                    let dist = distances.lock().unwrap();
                    if next_distance < dist[neighbor] {
                        Some((neighbor, next_distance))
                    } else {
                        None
                    }
                } else {
                    None
                }
            })
            .collect();

        // Sequentially apply the updates to avoid data races
        for (neighbor, next_distance) in updates {
            let mut dist = distances.lock().unwrap();
            if next_distance < dist[neighbor] {
                dist[neighbor] = next_distance;
                heap.push((next_distance, neighbor));
            }
        }
    }

    distances.lock().unwrap().clone()
}

// Function to generate a random graph (sequentially)
fn generate_graph(num_vertices: usize, max_weight: usize) -> Vec<Vec<Option<usize>>> {
    let mut rng = rand::thread_rng();
    let mut graph: Vec<Vec<Option<usize>>> = vec![vec![None; num_vertices]; num_vertices];

    for i in 0..num_vertices {
        for j in 0..num_vertices {
            if i != j && rng.gen_range(0..100) < 70 {
                graph[i][j] = Some(rng.gen_range(1..=max_weight));
            }
        }
    }

    graph
}

fn main() {
    let num_vertices = 5;
    let max_weight = 20;
    let start_vertex = 0;

    // Generate a random graph
    let graph = generate_graph(num_vertices, max_weight);

    // Print the generated graph
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

    // Run Dijkstra's algorithm
    let distances = dijkstra(&graph, start_vertex);

    // Print shortest distances from the start vertex
    println!("\nShortest distances from vertex {}:", start_vertex);
    for (i, &dist) in distances.iter().enumerate() {
        println!(
            "Vertex {}: {}",
            i,
            if dist == usize::MAX {
                "∞".to_string()
            } else {
                dist.to_string()
            }
        );
    }
}
