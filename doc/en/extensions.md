<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Extensions and Utilities

Useful extensions, helper functions, and utility patterns for working with graphs efficiently.

## Custom Properties

All vertices and some classes support custom properties for storing application-specific data:

```dart
// Store custom data on vertex
vertex.properties['myKey'] = 'myValue';
vertex.properties['counter'] = 0;
vertex.properties['forceMap'] = <Vector2>{};
vertex.properties['metadata'] = {'department': 'Engineering', 'level': 5};

// Retrieve data
var value = vertex.properties['myKey'];
var counter = vertex.properties['counter'] as int;
var color = vertex.properties['color'] as Color?;

// Check existence
if (vertex.properties.containsKey('myKey')) {
  print('Property exists');
}

// Use putIfAbsent for safe initialization
vertex.properties.putIfAbsent('counter', () => 0);
vertex.properties.putIfAbsent('visits', () => []);

// Remove property
vertex.properties.remove('myKey');
```

## Caching and Performance

### Vertex Lookup Cache

The graph maintains an automatic cache for O(1) vertex lookups:

```dart
// Graph automatically maintains keyCache
// Access is very fast
var vertex = graph.keyCache[vertexId];

// Instead of slow linear search
// var vertex = graph.vertexes.firstWhere((v) => v.id == vertexId);
```

### Edge Lookup Cache

Efficient lookup of edges between two vertices:

```dart
// Get all edges from vertex A to vertex B
List<Edge> edges = graph.edgesFromTwoVertex(vertexA, vertexB);

// Multigraph support: may return multiple edges
if (edges.isNotEmpty) {
  print('Found ${edges.length} connection(s)');
}

// For self-loops
List<Edge> selfLoops = graph.edgesFromTwoVertex(vertex, vertex);

// Clear cache when modifying edges
graph.edgeCacheMap.clear();
```

### Computed Properties Cache

Cache expensive computations on vertices:

```dart
// Cache neighbor count (updated when edges change)
vertex.properties['_degree_cached'] = vertex.degree;

// Cache common neighbors (expensive computation)
void cacheCommonNeighbors(Vertex a, Vertex b) {
  const String cacheKey = '_common_neighbors';
  vertex.properties.putIfAbsent(cacheKey, () {
    return a.sameNeighbors(b);
  });
}

// Invalidate cache when graph changes
void invalidateCache() {
  graph.vertexes.forEach((v) {
    v.properties.remove('_cached_metrics');
  });
}
```

## Common Helper Functions

### Find Common Neighbors

```dart
// Built-in method on Vertex
Set<Vertex> commonNeighbors = vertexA.sameNeighbors(vertexB);

// Manual implementation for custom logic
Set<Vertex> getCommonNeighbors(Vertex a, Vertex b) {
  final neighborsA = a.neighbors.toSet();
  final neighborsB = b.neighbors.toSet();
  return neighborsA.intersection(neighborsB);
}

// Find second-degree neighbors (neighbors of neighbors)
Set<Vertex> getSecondDegreeNeighbors(Vertex vertex) {
  final secondDegree = <Vertex>{};
  for (var neighbor in vertex.neighbors) {
    secondDegree.addAll(neighbor.neighbors);
  }
  secondDegree.remove(vertex);  // Don't include self
  return secondDegree;
}
```

## Serialization

### Convert Graph to JSON

```dart
Map<String, dynamic> graphToJson(Graph graph) {
  return {
    'vertices': graph.vertexes.map((v) => {
      'id': v.id.toString(),
      'tag': v.tag,
      'tags': v.tags.toList(),
      'position': {
        'x': v.position.dx,
        'y': v.position.dy,
      },
      'radiusZoom': v.radiusZoom,
      'visible': v.visible,
    }).toList(),
    'edges': graph.edges.map((e) => {
      'ranking': e.ranking,
      'edgeName': e.edgeName,
      'fromId': e.start.id.toString(),
      'toId': e.end?.id.toString(),
      'visible': e.visible,
    }).toList(),
  };
}

// Convert back from JSON
Graph graphFromJson(Map<String, dynamic> json) {
  final graph = Graph<String>();
  
  // Add vertices
  final vertexMap = <String, Vertex>{};
  for (final vJson in json['vertices'] as List) {
    final vertex = Vertex<String>(vJson['id']);
    vertex.tag = vJson['tag'];
    vertex.radiusZoom = vJson['radiusZoom'];
    vertex.visible = vJson['visible'];
    graph.addVertex(vertex);
    vertexMap[vJson['id']] = vertex;
  }
  
  // Add edges
  for (final eJson in json['edges'] as List) {
    final from = vertexMap[eJson['fromId']];
    final to = eJson['toId'] != null ? vertexMap[eJson['toId']] : null;
    
    if (from != null) {
      final edge = Edge(
        ranking: eJson['ranking'],
        edgeName: eJson['edgeName'],
        start: from,
        end: to,
      );
      edge.visible = eJson['visible'];
      graph.addEdge(edge);
    }
  }
  
  return graph;
}
```


## Further Reading

- [Models](models.md) — Vertex and Edge properties
- [Algorithms](algorithms.md) — Custom algorithm implementations
- [Convertors](convertors.md) — Data transformation patterns

---

**Version:** 2.x | **License:** Apache 2.0
