<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Quick Start

Create your first interactive graph visualization in just a few minutes! This guide walks you through the essential steps to set up and display a functional graph.

## 1. Installation

Add the package to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_graph_view: ^2.0.0
```

Then run:
```bash
flutter pub get
```

## 2. Prepare Your Data

Create a data structure containing vertices (nodes) and edges (connections):

```dart
final graphData = {
  'vertexes': [
    {'id': '1', 'tag': 'user', 'data': null},
    {'id': '2', 'tag': 'user', 'data': null},
    {'id': '3', 'tag': 'admin', 'data': null},
  ],
  'edges': [
    {'ranking': 1, 'edgeName': 'follows', 'srcId': '1', 'dstId': '2'},
    {'ranking': 2, 'edgeName': 'manages', 'srcId': '3', 'dstId': '1'},
  ]
};
```

The `MapConvertor` (the default data converter) expects this structure. If your data is in a different format, you can write a custom `DataConvertor` to transform it.

### Vertex Structure

```dart
{
  'id': 'unique_identifier',           // Required: identifies the vertex
  'tag': 'primary_type',               // Required: used for styling and filtering
  'tags': ['tag1', 'tag2'],            // Optional: additional classification tags
  'data': {...}                        // Optional: custom business data object
}
```

### Edge Structure

```dart
{
  'ranking': 1,                        // Required: priority/ordering of edges
  'edgeName': 'connection_type',       // Required: edge type identifier (e.g., 'follows', 'owns')
  'srcId': 'source_vertex_id',         // Required: ID of the source vertex
  'dstId': 'target_vertex_id',         // Required: ID of the target vertex
  'data': {...}                        // Optional: custom business data for the edge
}
```

## 3. Set Up a Data Converter

For Map-based data, use the built-in `MapConvertor`:

```dart
import 'package:flutter_graph_view/flutter_graph_view.dart';

final convertor = MapConvertor();
```

This converter transforms your raw data into `Graph`, `Vertex`, and `Edge` models. If your data comes from JSON, REST APIs, or custom objects, you can extend `DataConvertor` for custom transformation logic.

## 4. Choose a Layout Algorithm

The layout algorithm determines how nodes are positioned. Here are the most common options:

### Force Directed (Recommended for Most Cases)

Simulates physical forces (springs and repulsion) to create natural, readable layouts. Excellent for general-purpose graph visualization:

```dart
final algorithm = ForceDirected(
  decorators: [
    HookeDecorator(
      length: 100,           // Natural spring length (in canvas units)
      k: 0.003,             // Spring stiffness constant
    ),
    CoulombDecorator(
      k: 5000,              // Repulsion strength between all node pairs
    ),
  ],
);
```

**When to use:** Networks, social graphs, organizational structures, dependency diagrams.

### Circle Layout

Arranges all nodes in a perfect circle. Useful when node order matters or you want a uniform, symmetric layout:

```dart
final algorithm = CircleLayout();
```

## 5. Configure Visual Styling

### Vertex Colors

Map vertex colors by tag (primary) or by index (fallback):

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..tagColor = {
      'user': Colors.blue,
      'admin': Colors.red,
      'bot': Colors.green,
    }
    ..hoverOpacity = 0.3;
```

### Background Color

```dart
final options = Options()
  ..backgroundBuilder = (context) => Container(
    color: Colors.grey[900],
  );
```

### Text Display

```dart
options.showText = true;
options.textGetter = (vertex) => vertex.id.toString();
```

## 6. Create Your First Widget

Combine all components into a Flutter widget:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class GraphPage extends StatelessWidget {
  final graphData = {
    'vertexes': [
      {'id': '1', 'tag': 'user'},
      {'id': '2', 'tag': 'user'},
      {'id': '3', 'tag': 'admin'},
    ],
    'edges': [
      {'ranking': 1, 'edgeName': 'follows', 'srcId': '1', 'dstId': '2'},
      {'ranking': 2, 'edgeName': 'manages', 'srcId': '3', 'dstId': '1'},
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My First Graph')),
      body: FlutterGraphWidget(
        data: graphData,
        convertor: MapConvertor(),
        algorithm: ForceDirected(
          decorators: [
            HookeDecorator(length: 100, k: 0.003),
            CoulombDecorator(k: 5000),
          ],
        ),
        options: Options()
          ..graphStyle = GraphStyle()
            ..tagColor = {
              'user': Colors.blue,
              'admin': Colors.red,
            },
      ),
    );
  }
}
```

## 7. Add Interactivity

### Display Data Panels on Hover

Show contextual information when hovering over nodes or edges:

```dart
options.vertexPanelBuilder = (vertex) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [BoxShadow(blurRadius: 4)],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ID: ${vertex.id}', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Tag: ${vertex.tag}'),
        Text('Degree (Connections): ${vertex.degree}'),
      ],
    ),
  );
};

options.edgePanelBuilder = (edge) {
  return Container(
    padding: EdgeInsets.all(12),
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Type: ${edge.edgeName}', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('From: ${edge.start.id} → ${edge.end?.id ?? "?"}'),
        Text('Ranking: ${edge.ranking}'),
      ],
    ),
  );
};
```

### React to Tap Events

```dart
options.onVertexTapDown = (vertex, event) {
  print('Vertex tapped (pressed): ${vertex.id}');
  vertex.picked = true;  // Visual feedback
};

options.onVertexTapUp = (vertex, event) {
  print('Vertex tapped (released): ${vertex.id}');
  vertex.picked = false;
};

options.onVertexTapCancel = (vertex, event) {
  print('Vertex tap cancelled: ${vertex.id}');
  vertex.picked = false;
};
```

## 8. Performance Tips for Large Graphs

For graphs with thousands of nodes, optimize performance:

```dart
// Disable expensive hit detection if you don't need tap/hover
options.enableHit = false;

// Hide text rendering for better performance
options.showText = false;

// Use a faster layout algorithm (Circle is faster than ForceDirected)
algorithm = CircleLayout();

// Pause the layout algorithm when not needed
// (add PauseDecorator to the decorators list)
algorithm.decorators?.add(PauseDecorator());

// Reduce animation frame rate or resolution
options.scale.value = 0.5;  // Render at half resolution
```

## Next Steps

Now that you have a working graph, explore these topics to deepen your understanding:

- **[Data Models](models.md)** — Understand Graph, Vertex, and Edge in detail
- **[Layout Algorithms](algorithms.md)** — Learn about force-directed, circle, and custom layouts
- **[Styling](styles.md)** — Advanced color, shape, and text customization
- **[Decorators](decorators.md)** — Add physics, persistence, and custom behaviors
- **[Graph Options](options.md)** — Full configuration reference
- **[Data Converters](convertors.md)** — Adapt your data format to the library

---

**Version:** 2.x | **License:** Apache 2.0
