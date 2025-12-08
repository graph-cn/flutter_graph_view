<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Graph Options

The `Options` class is the central configuration hub for controlling graph behavior, interactivity, and visual presentation. This document covers configuration, interaction handling, and integration with other components.

> **Note:** For visual styling (colors, fonts, strokes), see [Styles](styles.md). This document focuses on behavior and UI layout configuration.

## Options Overview

```dart
class Options {
  // Component rendering
  GraphComponentBuilder graphComponentBuilder = GraphComponentCanvas.new;
  
  // Hover/interaction panels
  VertexPanelBuilder? vertexPanelBuilder;
  EdgePanelBuilder? edgePanelBuilder;
  Widget? vertexTapUpPanel;
  
  // Shapes
  VertexShape vertexShape = VertexCircleShape();
  EdgeShape edgeShape = EdgeLineShape();
  
  // Styling (see Styles.md for color configuration)
  GraphStyle graphStyle = GraphStyle();
  BackgroundBuilder backgroundBuilder;
  
  // Interaction
  bool enableHit = true;
  dynamic Function(Vertex vertex, dynamic)? onVertexTapDown;
  dynamic Function(Vertex vertex, dynamic)? onVertexTapUp;
  dynamic Function(Vertex vertex, dynamic)? onVertexTapCancel;
  
  // Zoom/scale limits
  Vector2 scaleRange = Vector2(0.05, 5.0);
  ValueNotifier<double> get scale => ...;
  ValueNotifier<Offset> get offset => ...;
  
  // Text configuration
  bool showText = true;
  String Function(Vertex) textGetter = (v) => '${v.id}';
  String? Function(Vertex) imgUrlGetter = (v) => null;
  
  // Panel sizing and timing
  Duration? panelDelay;
  double horizontalControllerHeight = 50;
  double verticalControllerWidth = 340;
  double vertexTapUpPanelWidth = 430;
  
  // References (auto-injected)
  Graph? graph;
}
```

## Vertex and Edge Shapes

Configure the visual form of nodes and connections:

```dart
// Vertex shapes
options.vertexShape = VertexCircleShape();      // Default: circular
options.vertexShape = VertexDiamondShape();     // Diamond with rounded corners

// Edge shapes
options.edgeShape = EdgeLineShape();            // Default: straight line
options.edgeShape = EdgeLineShape(scaleLoop: 1.5);  // Larger self-loop arcs
```

## Interaction and Hit Detection

### Enable/Disable Hit Testing

Hit testing (click/hover detection) impacts performance. Disable for large graphs if you don't need interaction:

```dart
// Enable hit detection (default)
options.enableHit = true;

// Disable for better performance on large graphs
options.enableHit = false;
```

### Vertex Tap Callbacks

Handle user interactions on vertices:

```dart
// Called when user presses down on a vertex
options.onVertexTapDown = (vertex, event) {
  print('Pressed: ${vertex.id}');
  vertex.picked = true;  // Visual feedback
};

// Called when user releases the vertex
options.onVertexTapUp = (vertex, event) {
  print('Released: ${vertex.id}');
  vertex.picked = false;
};

// Called when press is cancelled (e.g., moved out while pressed)
options.onVertexTapCancel = (vertex, event) {
  print('Cancelled: ${vertex.id}');
  vertex.picked = false;
};
```

## Zoom and Pan

### Scale Range (Zoom Limits)

Control minimum and maximum zoom levels:

```dart
// Default: 5% to 500% zoom
options.scaleRange = Vector2(0.05, 5.0);

// More restrictive (don't zoom too far out or in)
options.scaleRange = Vector2(0.5, 2.0);

// Very permissive (allow extreme zoom)
options.scaleRange = Vector2(0.01, 10.0);

// Zoom values
options.scale.value = 1.0;  // 100% (normal size)
options.scale.value = 0.5;  // 50% (zoomed out)
options.scale.value = 2.0;  // 200% (zoomed in)

// Pan/offset
options.offset.value = Offset(100, 50);  // Move canvas
```

## Text Configuration

### Display and Formatting

```dart
// Show/hide vertex labels
options.showText = true;    // Default: visible
options.showText = false;   // Hidden for cleaner look

// Customize label text
options.textGetter = (vertex) => '${vertex.id}';

// Multi-line labels
options.textGetter = (vertex) {
  return '${vertex.id}\n(degree: ${vertex.degree})';
};

// Custom data from business object
options.textGetter = (vertex) {
  if (vertex.data is Map) {
    return vertex.data['displayName'] ?? '${vertex.id}';
  }
  return '${vertex.id}';
};
```

### Images on Vertices

```dart
// Return image URL for vertices, null for text label
options.imgUrlGetter = (vertex) {
  if (vertex.tag == 'user') {
    return 'https://api.example.com/avatars/${vertex.id}.jpg';
  }
  return null;  // Use text label instead
};
```

## Data Panels (Hover/Tap)

### Vertex Panel (Hover Information)

Show contextual data when user hovers over a vertex:

```dart
options.vertexPanelBuilder = (vertex) {
  return Container(
    width: 280,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 8,
          offset: Offset(0, 2),
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Node Details',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _panelRow('ID', '${vertex.id}'),
        _panelRow('Type', vertex.tag),
        _panelRow('Connections', '${vertex.degree}'),
        if (vertex.data != null)
          _panelRow('Data', '${vertex.data}'),
      ],
    ),
  );
};

Widget _panelRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Text('$label:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}
```

### Edge Panel (Hover Information)

Show information about edges on hover:

```dart
options.edgePanelBuilder = (edge) {
  return Container(
    padding: EdgeInsets.all(12),
    color: Colors.white,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Type: ${edge.edgeName}'),
        Text('From: ${edge.start.id}'),
        if (edge.end != null)
          Text('To: ${edge.end!.id}'),
        if (edge.data != null)
          Text('Data: ${edge.data}'),
      ],
    ),
  );
};
```

### Tap Panel (Click Information)

Show detailed panel when user taps a vertex:

```dart
options.vertexTapUpPanel = Container(
  width: 400,
  padding: EdgeInsets.all(20),
  color: Colors.white,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Detailed View', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      SizedBox(height: 16),
      Text('Tapped vertex info goes here'),
      // Additional detailed content
    ],
  ),
);
```

## Panel Sizing

Control the dimensions of UI panels:

```dart
// Height of horizontal control panel (bottom)
options.horizontalControllerHeight = 50;   // Default: 50

// Width of vertical control panel (right side)
options.verticalControllerWidth = 340;     // Default: 340

// Width of tap-up detail panel
options.vertexTapUpPanelWidth = 430;       // Default: 430

// Delay before showing hover panel
options.panelDelay = Duration(milliseconds: 300);
```

## Background

Customize the canvas background:

```dart
// Transparent background
options.backgroundBuilder = (context) => Container(
  color: Colors.transparent,
);

// Dark theme background
options.backgroundBuilder = (context) => Container(
  color: Colors.grey[900],
);

// Gradient background
options.backgroundBuilder = (context) => Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue[900]!, Colors.purple[900]!],
    ),
  ),
);
```

## Complete Configuration Example

```dart
final options = Options()
  // Shapes
  ..vertexShape = VertexCircleShape()
  ..edgeShape = EdgeLineShape(scaleLoop: 1.2)
  
  // Interaction
  ..enableHit = true
  ..onVertexTapDown = (vertex, event) {
    print('Selected: ${vertex.id}');
    vertex.picked = true;
  }
  ..onVertexTapUp = (vertex, event) {
    vertex.picked = false;
  }
  
  // Zoom
  ..scaleRange = Vector2(0.1, 3.0)
  
  // Text
  ..showText = true
  ..textGetter = (vertex) => '${vertex.id}'
  
  // Panels
  ..vertexPanelBuilder = (vertex) => _buildVertexPanel(vertex)
  ..edgePanelBuilder = (edge) => _buildEdgePanel(edge)
  ..panelDelay = Duration(milliseconds: 200)
  ..horizontalControllerHeight = 60
  ..verticalControllerWidth = 350
  
  // Styling (see Styles.md)
  ..graphStyle = GraphStyle()
    ..tagColor = {'user': Colors.blue, 'admin': Colors.red}
    ..hoverOpacity = 0.3
  
  // Background
  ..backgroundBuilder = (ctx) => Container(color: Colors.grey[900]);
```

## State Observables

`Options` exposes observables for monitoring and controlling state:

```dart
// Observe scale changes (zoom level)
options.scale.addListener(() {
  print('Zoom level: ${options.scale.value}');
});

// Observe pan offset changes
options.offset.addListener(() {
  print('Pan offset: ${options.offset.value}');
});

// Observe refresh/timestamp (animation frame trigger)
// This notifies when the graph should redraw
options.refreshData(() {
  // Rebuild the widget
});
```

## Integration Notes

`Options` is automatically injected into:
- `Graph.options` — automatically set by FlutterGraphWidget
- `Vertex` styling lookups — for colors, text styles, visibility
- `Edge` rendering — for shape and styling
- Decorators — can read/modify options during execution

Modifying options after graph creation triggers redraws automatically through the observable pattern.

## Further Reading

- [Styles](styles.md) — Color, font, stroke configuration
- [Dashboard](dashboard.md) — Advanced overlay panels
- [Quick Start](quick_start.md) — See Options in a working example

---

**Version:** 2.x | **License:** Apache 2.0
