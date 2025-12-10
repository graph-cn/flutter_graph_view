<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Data Converters

Data converters transform your business data (from APIs, databases, files, etc.) into the Graph, Vertex, and Edge models that Flutter Graph View understands. This document covers creating and customizing converters for your specific data formats.

> **Quick Start Users:** For basic usage with Map/JSON data, see [Quick Start](quick_start.md). This document is for custom data structures.

## DataConvertor Interface

The abstract base class defines the contract for all converters:

```dart
abstract class DataConvertor<V, E> {
  /// Transform a business vertex into a library Vertex model
  Vertex convertVertex(V v, Graph graph);
  
  /// Transform a business edge into a library Edge model
  Edge convertEdge(E e, Graph graph);
  
  /// Transform complete business data structure into a Graph
  Graph convertGraph(dynamic data, {Graph? graph});
  
  /// Register a converted vertex into the graph (caching, tag tracking)
  void vertexAsGraphComponse(V v, Graph<dynamic> g, Vertex<dynamic> vertex);
  
  /// Register a converted edge into the graph (relationship tracking)
  void edgeAsGraphComponse(E e, Graph<dynamic> g, Edge result);
  
  /// Index edges between two specific vertices (for multigraph support)
  void fillEdgesBetween(Graph g, Edge result);
  
  /// Add an edge with deduplication (prevents duplicate edges)
  Edge addEdge(E e, Graph graph);
  
  /// Add a vertex with deduplication (prevents duplicate vertices)
  Vertex addVertex(V v, Graph graph);
}
```

## MapConvertor (Built-in Default)

For JSON/Map-formatted data, use the provided `MapConvertor`:

### Expected Data Format

```dart
final data = {
  'vertexes': [
    {
      'id': 'unique_identifier',    // Required
      'tag': 'primary_type',         // Required
      'tags': ['tag1', 'tag2'],     // Optional: additional tags
      'data': {...}                 // Optional: custom business data
    },
    // ... more vertices
  ],
  'edges': [
    {
      'ranking': 1,                  // Required: priority/order
      'edgeName': 'relationship_type', // Required: edge type name
      'srcId': 'source_vertex_id',   // Required: ID of source vertex
      'dstId': 'target_vertex_id',   // Required: ID of target vertex
      'data': {...}                  // Optional: custom business data
    },
    // ... more edges
  ]
};

final convertor = MapConvertor();
final graph = convertor.convertGraph(data);
```

## Creating Custom Converters

For non-standard data formats, extend `DataConvertor`:

### Example: Converting Custom Business Classes

Suppose you have custom Dart classes for an organizational structure:

```dart
// Business domain classes
class Employee {
  String id;
  String name;
  String department;
  String role;
  List<String> skills;

  Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.role,
    this.skills = const [],
  });
}

class WorkRelationship {
  String managerId;
  String subordinateId;
  String type;  // 'manages', 'mentors', 'collaborates'
  double strength;

  WorkRelationship({
    required this.managerId,
    required this.subordinateId,
    required this.type,
    this.strength = 1.0,
  });
}

class Organization {
  List<Employee> employees;
  List<WorkRelationship> relationships;

  Organization({
    required this.employees,
    required this.relationships,
  });
}
```

Now create a converter:

```dart
class OrganizationConvertor extends DataConvertor<Employee, WorkRelationship> {
  
  @override
  Vertex convertVertex(Employee employee, Graph graph) {
    var vertex = Vertex();
    vertex.id = employee.id;
    vertex.tag = employee.department;      // Color by department
    vertex.tags = [employee.department, employee.role] + employee.skills;
    vertex.data = employee;                // Store original object
    return vertex;
  }

  @override
  Edge convertEdge(WorkRelationship relationship, Graph graph) {
    var edge = Edge();
    edge.ranking = (relationship.strength * 100).toInt();
    edge.edgeName = relationship.type;
    edge.start = graph.keyCache[relationship.managerId]!;
    edge.end = graph.keyCache[relationship.subordinateId];
    edge.data = relationship;
    return edge;
  }

  @override
  Graph convertGraph(dynamic data, {Graph? graph}) {
    var result = graph ?? Graph();
    result.data = data;

    if (data is Organization) {
      // Convert all employees to vertices
      for (var employee in data.employees) {
        addVertex(employee, result);
      }
      
      // Convert all relationships to edges
      for (var relationship in data.relationships) {
        addEdge(relationship, result);
      }
    }
    return result;
  }
}
```

### Using Your Custom Converter

```dart
final organization = Organization(
  employees: [
    Employee(
      id: 'emp001',
      name: 'Alice Chen',
      department: 'Engineering',
      role: 'Staff Engineer',
      skills: ['Architecture', 'Leadership', 'Mentoring'],
    ),
    Employee(
      id: 'emp002',
      name: 'Bob Martinez',
      department: 'Engineering',
      role: 'Junior Engineer',
      skills: ['Dart', 'Flutter'],
    ),
    Employee(
      id: 'emp003',
      name: 'Carol Singh',
      department: 'Product',
      role: 'Product Manager',
      skills: ['Strategy', 'Analytics'],
    ),
  ],
  relationships: [
    WorkRelationship(
      managerId: 'emp001',
      subordinateId: 'emp002',
      type: 'manages',
      strength: 1.0,
    ),
    WorkRelationship(
      managerId: 'emp001',
      subordinateId: 'emp003',
      type: 'collaborates',
      strength: 0.7,
    ),
  ],
);

// Use the custom converter
final widget = FlutterGraphWidget(
  data: organization,
  convertor: OrganizationConvertor(),
  algorithm: ForceDirected(
    decorators: [
      HookeDecorator(length: 100, k: 0.003),
      CoulombDecorator(k: 5000),
    ],
  ),
  options: Options()
    ..graphStyle = GraphStyle()
      ..tagColor = {
        'Engineering': Colors.blue[400]!,
        'Product': Colors.green[400]!,
        'Sales': Colors.orange[400]!,
      },
);
```

## Advanced Customization Hooks

Extend the converter for additional processing during graph construction:

```dart
class EnhancedOrganizationConvertor extends OrganizationConvertor {
  
  @override
  void vertexAsGraphComponse(employee, g, vertex) {
    super.vertexAsGraphComponse(employee, g, vertex);
    
    // Custom logic: log all added vertices
    print('[Convertor] Added vertex: ${vertex.id} (${employee.name})');
    
    // Custom: initialize decorator properties
    vertex.properties['department'] = employee.department;
    vertex.properties['joinDate'] = null;
  }

  @override
  void edgeAsGraphComponse(relationship, g, result) {
    super.edgeAsGraphComponse(relationship, g, result);
    
    // Custom logic: validate edge integrity
    if (result.end == null) {
      print('[Warning] Edge has no target vertex: ${result.edgeName}');
    }
    
    // Custom: track relationship metadata
    result.data['processedAt'] = DateTime.now();
  }
}
```

## Conversion Pipeline

Understand the order of operations:

```
1. convertGraph() called
   ↓
2. For each vertex:
   - convertVertex(v) → Vertex object
   - addVertex(v) → deduplication check, cache insertion
   - vertexAsGraphComponse() → tag tracking, color assignment
   ↓
3. For each edge:
   - convertEdge(e) → Edge object
   - addEdge(e) → deduplication check
   - edgeAsGraphComponse() → relationship linking
   - fillEdgesBetween() → multigraph indexing
   ↓
4. Graph returned, ready for layout algorithm
```

## Best Practices

### 1. **Store Original Data**
Always keep a reference to the original business object in `vertex.data` or `edge.data`. This allows UI panels to access all original properties:

```dart
vertex.data = employee;  // Keep the Employee object
// Later, in a panel builder:
var name = (vertex.data as Employee).name;
```

### 2. **Use Tags for Semantics**
Tags drive coloring and filtering. Use meaningful, hierarchical tags:

```dart
vertex.tag = 'department';        // Primary grouping
vertex.tags = [
  'department',
  'role',
  ...skills                       // Secondary grouping
];
```

## Further Reading

- [Data Models](models.md) — Understand Vertex, Edge, and Graph structure
- [Styles](styles.md) — Color vertices based on tags assigned during conversion
- [Quick Start](quick_start.md) — See MapConvertor in action

---

**Version:** 2.x | **License:** Apache 2.0
