<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Layout Algorithms

Layout algorithms calculate the positions of vertices in 2D canvas space. They determine how your graph is visually arranged and are central to the visualization quality.

## GraphAlgorithm Interface

All layout algorithms extend `GraphAlgorithm` and follow this contract:

```dart
abstract class GraphAlgorithm {
  /// Decorators that modify or extend algorithm behavior
  List<GraphAlgorithm>? decorators;
  
  /// Reference to root algorithm (for decorators in chains)
  GraphAlgorithm? rootAlg;
  
  /// Canvas size in pixels
  Size? get size => $size.value;
  
  /// Center point of canvas
  Offset get center => Offset((size?.width ?? 0) / 2, (size?.height ?? 0) / 2);
  
  /// Default offset distance for positioning nodes from center
  /// Used by some algorithms to distribute nodes
  double get offset => min(center.dx, center.dy) * 0.4;
  
  /// Reference to the graph being processed
  Graph? graph;
  
  /// Main computation: calculate vertex position in current frame
  /// Called repeatedly (typically 60fps) until algorithm converges
  void compute(Vertex v, Graph graph);
  
  /// Called when a single vertex is loaded
  void onLoad(Vertex v);
  
  /// Called when entire graph is loaded (all vertices/edges added)
  void onGraphLoad(Graph graph);
  
  /// Called after user drags a vertex (useful for momentum)
  void afterDrag(Vertex vertex, Vector2 globalDelta);
  
  /// Called before merging new data with existing graph
  void beforeMerge(dynamic data);
  
  /// Called before loading data (reset state, etc)
  void beforeLoad(data);
}
```

## Algorithm Lifecycle

1. **Initialization**: Framework calls `setGlobalData(rootAlg, graph)` to set global references
2. **Loading**: Sequence of `beforeLoad()` → `onLoad()` → `onGraphLoad()`
3. **Positioning**: `compute()` called repeatedly for each vertex until stabilized
4. **Interaction**: `afterDrag()` and `beforeMerge()` during user interaction
5. **Reset**: `beforeLoad()` when data changes

## ForceDirected

Simulates physical forces (attraction and repulsion) between nodes to create natural, hierarchical layouts.

### Principles

- **Connected nodes attract** like springs (Hooke's Law) with configurable stiffness
- **All nodes repel** each other like electric charges (Coulomb's Law) with configurable strength
- **Iterative convergence**: Algorithm runs each frame until system reaches equilibrium
- **Momentum**: Nodes maintain velocity for smooth motion
- **Ideal for**: hierarchies, networks, social graphs, dependency visualization

### Basic Usage

```dart
final algorithm = ForceDirected(
  decorators: [
    HookeDecorator(
      length: 100,    // Preferred edge length (pixels)
      k: 0.003,       // Spring stiffness (0.001-0.01 range)
    ),
    CoulombDecorator(
      k: 5000,        // Repulsion strength (1000-50000 range)
    ),
  ],
);

widget = FlutterGraphWidget(
  data: graphData,
  algorithm: algorithm,
  // ...
);
```

### Configuration Details

```dart
// For tightly clustered graphs, increase spring stiffness
HookeDecorator(length: 80, k: 0.01)

// For sparse graphs with clear separation, increase repulsion
CoulombDecorator(k: 10000)

// Combine with velocity damping for stability
// (See PauseDecorator and motion control in decorators.md)
```

### When to Use ForceDirected

✓ Social networks (people connections)
✓ Dependency graphs (module relationships)
✓ Organizational hierarchies
✓ Knowledge graphs with semantic relationships

✗ Trees (use ForceDirected but with careful tuning)
✗ Very large graphs (500+ nodes) - performance intensive

## CircleLayout

Positions all nodes evenly distributed on a circle around the center.

### Characteristics

- **Deterministic**: Same input = same output (unlike ForceDirected)
- **Simple and predictable**: Good for presentations and demos
- **Fast**: O(n) complexity, no iterations needed
- **Equal visibility**: All nodes at same distance from center
- **Edges clearly visible**: Especially good for examining connections

### Usage

```dart
final algorithm = CircleLayout();

widget = FlutterGraphWidget(
  data: graphData,
  algorithm: algorithm,
  // ...
);
```

### When to Use CircleLayout

✓ Small graphs (< 20 nodes)
✓ Presentations where predictability matters
✓ Bipartite graphs (arrange on opposing arcs)
✓ Initial layout before transitioning to ForceDirected
✓ Testing and validation

## RandomAlgorithm

Positions all nodes at random locations within canvas bounds.

### Characteristics

- **Non-deterministic**: Different each run
- **Useful for testing**: Load balancing, stress testing
- **Baseline**: Starting point for custom algorithms
- **No convergence**: Completes immediately
- **No iteration**: Better performance for testing

### Usage

```dart
final algorithm = RandomAlgorithm();

// Often used as temporary/test layout
widget = FlutterGraphWidget(
  data: graphData,
  algorithm: algorithm,
  // ...
);
```

## Algorithm Decorators

Decorators extend algorithm behavior without modifying the core algorithm. They follow composition-over-inheritance pattern.

### Purpose

- **Encapsulate reusable behaviors**: Forces, physics, persistence, pause/resume
- **Modular composition**: Mix and match features
- **Separation of concerns**: Algorithm calculates positions, decorators add features

### Decorator Pattern

```dart
final algorithm = ForceDirected(
  decorators: [
    HookeDecorator(length: 100, k: 0.003),      // Add spring forces
    CoulombDecorator(k: 5000),                  // Add repulsion forces
    PauseDecorator(),                           // Control pause/resume
    PersistenceDecorator(),                     // Save/restore state
    TimeCounterDecorator(maxIterations: 1000),  // Limit iterations
  ],
);
```

for more see the decorators section

## Dicas de Performance

### Para Grafos Grandes

1. Use `CircleLayout` para posição inicial rápida
2. Combine com `PauseDecorator` para pausar iterações
3. Limite iterações com `time_counter_decorator`
4. Desabilite física desnecessária

## Próximas Leituras

- [Decoradores](decorators.md) - Estender comportamentos
- [Opções](options.md) - Configurar comportamentos do algoritmo

---

**Version:** 2.x | **License:** Apache 2.0
