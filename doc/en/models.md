<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Data Models

The data models are the fundamental structures that power Flutter Graph View. Every visual element in a graph is represented by one of these core models. This document provides detailed API reference and usage patterns.

> **Note:** For an architectural overview and use cases, see [Overview](overview.md). This document focuses on detailed API reference.

## Graph<ID>

The root container that holds all vertices, edges, and metadata for a graph instance.

### Main Properties

```dart
class Graph<ID> {
  /// List of all vertices (nodes) in the graph
  final List<Vertex<ID>> vertexes = [];
  
  /// Set of all edges (connections) in the graph
  Set<Edge> edges = {};
  
  /// Cache for O(1) vertex lookup by ID
  Map<ID, Vertex<ID>> keyCache = {};
  
  /// Reference to the Options configuration object
  Options? options;
  
  /// Layout algorithm currently being used
  GraphAlgorithm? algorithm;
  
  /// Data converter that built this graph
  DataConvertor? convertor;
  
  /// Observable canvas size (synced from options)
  ValueNotifier<Size> get size => options!.size;
  
  /// Currently hovered vertex (under mouse cursor)
  Vertex<ID>? get hoverVertex => _hoverVertex;
  set hoverVertex(Vertex<ID>? v) { ... }
  
  /// Currently hovered edge
  Edge? hoverEdge;
  
  /// User-selected vertices (from tap/keyboard interactions)
  List<Vertex<ID>> pickedVertex = [];
  
  /// Original business data that was converted into this graph
  dynamic data;
  
  /// All unique tags found in all vertices
  List<String> allTags = [];
  
  /// All edge type names (edgeNames) found in all edges
  List<String> allEdgeNames = [];
  
  /// Internal mapping for quick access to edges between two vertices
  /// Key format: "${srcId}→${dstId}", value: list of edges
  Map<String, List<Edge>> edgesBetweenHash = {};
}
```

### Main Methods

```dart
/// Get all vertices marked as center/anchor points
List<Vertex> get centerVertexes {
  return vertexes.where((element) => element.isCenter).toList();
}

/// Determine if a data panel should be shown for a vertex
bool showPanel(Vertex<ID> v) { ... }

/// Get all edges connecting two specific vertices (handles multigraphs)
List<Edge> edgesFromTwoVertex(Vertex s, Vertex e) { ... }
```

## Vertex<ID>

Represents a single node in the graph with position, styling, connections, and business data.

### Main Properties

```dart
class Vertex<I> {
  /// Unique identifier for this vertex (generic type)
  late I id;
  
  /// Primary tag/classification (used for styling and grouping)
  late String tag;
  
  /// Whether to use a solid color vs gradient
  late bool solid;

  /// Scale factor for vertex radius (default 1.0)
  late double radiusScale;

  /// Additional tags for multi-classification (e.g., ["developer", "senior"])
  List<String>? tags;
  
  /// Outgoing edges (edges where this vertex is the start)
  Set<Edge> nextEdges = {};
  
  /// Incoming edges (edges where this vertex is the end)
  Set<Edge> prevEdges = {};
  
  /// Successor vertices (connected via outgoing edges)
  Set<Vertex<I>> nextVertexes = {};
  
  /// Predecessor vertices (connected via incoming edges)
  Set<Vertex<I>> prevVertexes = {};
  
  /// Total degree: count of all connections (in + out)
  int degree = 0;
  
  /// Whether this vertex is currently selected by user
  bool picked = false;
  
  /// Parent vertex in hierarchy (for layout algorithms)
  Vertex<I>? prevVertex;
  
  /// Depth in the hierarchy
  int deep = 1;
  
  /// Color list assigned to this vertex (by tag or randomly)
  List<Color> colors = [];
  
  /// 2D position on the canvas (computed by layout algorithm)
  Vector2 position = Vector2(0, 0);
  
  /// Original business data object associated with this vertex
  late dynamic data;
  
  /// Base radius size (before dynamic calculation)
  double _radius = 5;
  
  /// Computed radius: dynamically scales based on degree (connectivity)
  /// Formula: log(degree * 10 + 1) + base radius
  double get radius => (log(degree * 10 + 1)) + _radius;
  
  /// Optional custom size override (if specified, overrides computed radius)
  Size? size;
  
  /// Whether this vertex should be rendered
  bool visible = true;
  
  /// Whether this vertex is anchored to the center (for certain layouts)
  bool isCenter = false;
  
  /// Zoom/scale factor for this specific vertex
  double zoom = 1.0;
  
  /// Custom properties map for storing decorator/algorithm-specific data
  Map<String, dynamic> properties = {};
}
```

### Main Methods

```dart
/// Get all neighbors (both incoming and outgoing connections)
List<Vertex<I>> get neighbors => [...nextVertexes, ...prevVertexes];

/// Get all edges connecting this vertex
List<Edge> get neighborEdges => [...nextEdges, ...prevEdges];

/// Find common neighbors between this vertex and another
Set<Vertex<I>> sameNeighbors(Vertex<I> other) {
  return neighbors.toSet().intersection(other.neighbors.toSet());
}
```

### Usage Example

```dart
// Create and configure a vertex
var vertex = Vertex<String>();
vertex.id = "user_123";
vertex.tag = "person";
vertex.tags = ["person", "developer", "senior"];
vertex.data = {"name": "Alice Johnson", "role": "Engineer"};

// Check connectivity
print('Neighbors: ${vertex.neighbors.length}');
print('Degree: ${vertex.degree}');
print('Calculated Radius: ${vertex.radius}');

// Mark as selected
vertex.picked = true;

// Store custom data for decorators
vertex.properties['forceVector'] = Vector2(0.5, 1.0);
vertex.properties['iterationCount'] = 0;
```

## Edge

Represents a directed connection between two vertices with properties and custom data.

### Main Properties

```dart
class Edge {
  /// Ranking/priority for ordering edges (higher = higher priority)
  late int ranking;
  
  /// Edge type/relationship name (e.g., "follows", "manages", "owns")
  late String edgeName;
  
  /// Original business data for this edge
  late dynamic data;

  /// Source vertex (start of directed edge)
  late Vertex start;
  
  /// Whether to use solid color vs gradient
  late bool solid;

  /// Target vertex (end of directed edge), nullable for self-loops
  Vertex? end;
  
  /// Color list for this edge (by edgeName or random)
  late List<Color> colors;
  
  /// Whether this edge is currently hovered
  bool isHovered = false;
  
  /// Whether this edge should be rendered
  bool visible = true;
  
  /// Reference to the containing graph
  Graph? g;
  
  /// Optional custom path override for non-straight rendering
  Path? path;
}
```

### Computed Properties

```dart
/// True if this edge starts and ends at the same vertex (self-loop)
bool get isLoop => start == end;

/// Midpoint position between start and end vertices
Vector2 get position { ... }

/// Index for spacing multiple edges between same vertex pair
double get computeIndex { ... }

/// Order of this edge among all edges between the same two vertices
int get edgeIdx { ... }

/// Size/thickness of the edge (from edge shape)
Vector2 get size => g!.options!.edgeShape.size(this);

/// Zoom factor for rendering this edge
double get zoom => start.zoom;
```

### Usage Example

```dart
// Create and configure an edge
var edge = Edge();
edge.ranking = 100;
edge.edgeName = "follows";
edge.start = vertexA;
edge.end = vertexB;
edge.data = {
  "since": "2024-01-15",
  "strength": 0.8,
  "weight": 5
};

// Check properties
print('Is loop: ${edge.isLoop}');           // false
print('Midpoint: ${edge.position}');        // Vector2
print('Type: ${edge.edgeName}');            // "follows"
```

## Model Relationships

```
┌──────────────┐
│    Graph     │
├──────────────┤
│  vertexes[]  │──┐
│  edges{}     │  │
│  options     │  │
│  algorithm   │  │
│  convertor   │  │
└──────────────┘  │
                  │
         ┌────────┴────────┐
         │                 │
    ┌──────────┐       ┌───────┐
    │ Vertex   │       │ Edge  │
    ├──────────┤       ├───────┤
    │ id       │       │start  │───┐
    │ tag      │       │end    │   │
    │ position │       │data   │   │
    │ colors   │       │colors │   │
    │ data     │       └───────┘   │
    │ neighbors ───────────┐       │
    └──────────┘           │       │
        ▲                  │       │
        └──────────────────┴───────┘
```

This diagram shows:
- A `Graph` container holds `Vertex` and `Edge` lists
- Each `Vertex` has neighbors and edges connecting it
- Each `Edge` references its `start` and `end` vertices

## Tags and Coloring

Tags enable semantic classification and automated coloring:

```dart
// Multi-tag vertices for flexible categorization
vertex.tag = "person";                    // Primary
vertex.tags = ["person", "developer"];    // Additional

// Colors are assigned based on tags via GraphStyle
var tagColor = {
  "person": Colors.blue,
  "developer": Colors.amber,
  "manager": Colors.red,
};

// The rendering system uses these to color vertices
```

## Caching and Performance

The models employ strategic caching for O(1) operations:

```dart
// Vertex cache by ID
graph.keyCache[vertex.id] = vertex;  // O(1) insert/lookup

// Edge cache between vertices (handles multigraphs)
var key = "${srcId}→${dstId}";
graph.edgesBetweenHash[key] = [edge1, edge2];

// Tag and edge-name caches
graph.allTags = ["person", "developer", ...];
graph.allEdgeNames = ["follows", "manages", ...];
```

## Custom Properties

Both vertices and edges support arbitrary key-value storage for decorators and algorithms:

```dart
// Store algorithm-specific data
vertex.properties['forceVector'] = Vector2(x, y);
vertex.properties['iterationsSinceMove'] = 42;
vertex.properties['customColor'] = Colors.red;

// Retrieve with type safety
var force = vertex.properties['forceVector'] as Vector2?;
var iters = vertex.properties['iterationsSinceMove'] ?? 0;

// Check existence and default
vertex.properties.putIfAbsent('counter', () => 0);
```

## Type Safety

The `Vertex<ID>` and `Graph<ID>` are generic for type safety with your ID type:

```dart
// Graph with String IDs
Graph<String> stringGraph = Graph<String>();
var v = stringGraph.keyCache['user_123'];  // String key, String value

// Graph with int IDs
Graph<int> intGraph = Graph<int>();
var v2 = intGraph.keyCache[456];           // int key, int value

// Graph with custom object IDs
Graph<UserId> customGraph = Graph<UserId>();
var v3 = customGraph.keyCache[UserId('x')];
```

## Further Reading

- [Data Converters](convertors.md) — Transform business data into models
- [Layout Algorithms](algorithms.md) — Compute positions for vertices
- [Styles](styles.md) — Configure visual appearance based on tags

---

**Version:** 2.x | **License:** Apache 2.0
