<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Algorithm Decorators

Decorators implement the Decorator pattern to extend algorithm behavior without modifying the core algorithm. They allow clean composition of multiple concerns (forces, constraints, persistence, UI controls) while keeping the layout algorithm focused on position calculation.

## Decorator Pattern Concept

Decorators wrap and extend `GraphAlgorithm` behavior through composition:

```
┌──────────────────────────────────┐
│     FlutterGraphWidget           │
├──────────────────────────────────┤
│    GraphAlgorithm                │
│  ┌──────────────────────────────┐│
│  │  ForceMotionDecorator        ││
│  │  ┌──────────────────────────┐││
│  │  │ CoulombDecorator         │││
│  │  │ ┌──────────────────────┐ │││
│  │  │ │ HookeDecorator       │ │││
│  │  │ └──────────────────────┘ │││
│  │  └──────────────────────────┘││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

## Base Interface

All decorators extend `GraphAlgorithm`:

```dart
abstract class GraphAlgorithm {
  /// Nested decorators
  List<GraphAlgorithm>? decorators;
  
  /// Main computation method (called each frame per vertex)
  void compute(Vertex v, Graph graph);
  
  /// Called when individual vertex is loaded
  void onLoad(Vertex v);
  
  /// Called after user drags a vertex
  void afterDrag(Vertex vertex, Vector2 globalDelta);
  
  /// Called when entire graph finishes loading
  void onGraphLoad(Graph graph);
  
  /// UI overlays (optional)
  Widget Function()? horizontalOverlay;
  Widget Function()? verticalOverlay;
}
```

## Execution Cycle

### Graph Load: `onGraphLoad`

Called once when graph is first loaded:

```dart
void onGraphLoad(Graph graph) {
  beforeLoad(graph.data);
  for (var v in graph.vertexes) {
    onLoad(v);
  }
  // All decorators also execute
  for (var decorator in decorators ?? []) {
    decorator.onGraphLoad(graph);
  }
}
```

### Vertex Load: `onLoad`

Initialize individual vertex:

```dart
void onLoad(Vertex v) {
  // Initialize custom properties for this vertex
  v.properties['timeCounter'] = 0;
  v.properties['forceMap'] = <Vector2, double>{};
  v.properties['velocity'] = Vector2.zero();
  
  // Decorators initialize too
  for (var decorator in decorators ?? []) {
    decorator.onLoad(v);
  }
}
```

### Position Computation: `compute`

Called every frame for each vertex (e.g., 60 times per second):

```dart
void compute(Vertex v, Graph graph) {
  // Execute decorators first (allows layering)
  for (var decorator in decorators ?? []) {
    decorator.compute(v, graph);
  }
  
  // Then implement own logic
  // ...
}
```

## Force-Based Decorators

### ForceDecorator (Base)

Abstract base for force calculation. Stores forces in `vertex.properties['forceMap']`:

```dart
var algorithm = ForceDirected(
  decorators: [
    ForceDecorator(sameTagsFactor: 0.5),
  ],
);
```

### HookeDecorator

Implements Hooke's Law: `F = -k(x - L₀)`

Creates spring-like attraction between connected nodes:

```dart
HookeDecorator(
  length: 150,           
  k: 0.002,              
  degreeFactor: (len, degree) => len + degree * 10,
)
```

### CoulombDecorator

Implements Coulomb's Law: `F = k/r²`

Repulsive electrostatic force between all nodes:

```dart
CoulombDecorator(k: 8000)  // Stronger repulsion
```

### CoulombCenterDecorator

Repulsive force emanating from canvas center:

```dart
class CoulombCenterDecorator extends ForceDecorator {
  double k;
  
  CoulombCenterDecorator({this.k = 5000});
}
```

### CoulombReverseDecorator

Inverse of Coulomb: **attraction** between all nodes:

```dart
class CoulombReverseDecorator extends ForceDecorator {
  double k;
  
  CoulombReverseDecorator({this.k = 5000});
}
```

### CoulombBorderDecorator

Repulsive force from canvas boundaries:

```dart
class CoulombBorderDecorator extends ForceDecorator {
  double k;
  double borderOffset;
  
  CoulombBorderDecorator({
    this.k = 5000,
    this.borderOffset = 50,
  });
}
```
## Decorator Composition

Combine multiple decorators to create complex behaviors:

```dart
final algorithm = ForceDirected(
  decorators: [
    // Core forces
    HookeDecorator(length: 100, k: 0.003),
    CoulombDecorator(k: 5000),
    CoulombBorderDecorator(borderOffset: 50),
    
    // Motion
    ForceMotionDecorator(damping: 0.95),
    
    // Control
    PauseDecorator(),
    TimeCounterDecorator(maxIterations: 2000),
    
    // Persistence
    PersistenceDecorator(),
  ],
);

// Usage
widget = FlutterGraphWidget(
  data: graphData,
  algorithm: algorithm,
  options: options,
);
```

## Execution Order

Decorators execute in the order they're added:

```dart
// Frame 1: Each vertex gets processed by all decorators in sequence
decorators[0].compute(vertex, graph);  // HookeDecorator
decorators[1].compute(vertex, graph);  // CoulombDecorator
decorators[2].compute(vertex, graph);  // CoulombBorderDecorator
decorators[3].compute(vertex, graph);  // ForceMotionDecorator
// ... and so on
```

**Important:** Order matters! Place force decorators before motion decorator so forces are calculated before movement.

## Performance Tips

1. **Minimize decorator count** — Each decorator adds per-frame cost
2. **Use TimeCounterDecorator** — Stop early if layout stabilizes
3. **Profile with PauseDecorator** — Pause to check if more iterations help
4. **Avoid heavy computations in compute()** — Can block rendering

## Further Reading

- [Algorithms](algorithms.md) — Base algorithms and selection guide
- [Options](options.md) — Configure decorators at runtime

---

**Version:** 2.x | **License:** Apache 2.0
