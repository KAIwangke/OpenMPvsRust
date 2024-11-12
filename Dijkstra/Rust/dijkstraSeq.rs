use rand::Rng;
use std::collections::BinaryHeap;
use std::i32;

fn dijkstra(graph: &Vec<Vec<Option<usize>>>, start: usize) -> Vec<i32> {
    let n = graph.len();
    let mut distances = vec![i32::MAX; n]; // Initialize all distances to infinity
    distances[start] = 0; // Distance to start node is 0

    let mut heap = BinaryHeap::new();
    heap.push((0, start)); // Start with the source node (distance 0, start node)

    while let Some((distance, vertex)) = heap.pop() {
        // Convert back to positive distance
        let distance = -distance;

        // Skip outdated entries in the heap
        if distance > distances[vertex] {
            continue;
        }

        // Process each neighbor of the current vertex
        for (neighbor, &weight) in graph[vertex].iter().enumerate() {
            if let Some(weight) = weight {
                let next_distance = distance + weight as i32;

                // If we find a shorter path to `neighbor`, update the distance and push it to the heap
                if next_distance < distances[neighbor] {
                    distances[neighbor] = next_distance;
                    heap.push((-next_distance, neighbor)); // Use negative to simulate min-heap
                }
            }
        }
    }

    distances
}

// Function to generate a random graph
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
            if dist == i32::MAX {
                "∞".to_string()
            } else {
                dist.to_string()
            }
        );
    }
}
