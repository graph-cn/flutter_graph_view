<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Dashboard and Overlays

Create data panels and interactive controls that appear while the user interacts with the graph.

## Overlay Concept

The overlay system allows you to display panels in three locations:

```
┌────────────────────────────────────────────┐
│  Left Overlay        |     Canvas      |   │
│                      |                 |   │
│  Vertical            |                 |   │
│  Overlay             |                 |   │
│                      |                 |   │
├──────────────────────┴─────────────────────┤
│        Horizontal Overlay                  │
└────────────────────────────────────────────┘
```

## Overlay Types

### 1. Vertical Overlay (Right)

Vertical panel on the right side of the canvas.

```dart
class MyVerticalOverlay extends GraphAlgorithm {
  @override
  Widget Function()? get verticalOverlay => () {
    return Container(
      width: 300,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text('Controls', style: TextStyle(fontSize: 18)),
          ),
          Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(title: Text('Zoom')),
                ListTile(title: Text('Colors')),
                ListTile(title: Text('Filters')),
              ],
            ),
          ),
        ],
      ),
    );
  };
}
```

### 2. Horizontal Overlay (Bottom)

Horizontal panel at the bottom of the canvas.

```dart
class MyHorizontalOverlay extends GraphAlgorithm {
  @override
  Widget Function()? get horizontalOverlay => () {
    return Container(
      height: 80,
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => print('Reset'),
          ),
          IconButton(
            icon: Icon(Icons.play_arrow, color: Colors.white),
            onPressed: () => print('Play'),
          ),
          IconButton(
            icon: Icon(Icons.pause, color: Colors.white),
            onPressed: () => print('Pause'),
          ),
        ],
      ),
    );
  };
}
```

### 3. Left Overlay (Left)

Vertical panel on the left side.

```dart
class MyLeftOverlay extends GraphAlgorithm {
  @override
  Widget Function()? get leftOverlay => () {
    return Container(
      width: 250,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Legend',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            ...options.graphStyle.tagColor!.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: entry.value,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(entry.key),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  };
}
```

## Hover Panels

### Vertex Panel on Hover

```dart
options.vertexPanelBuilder = (vertex) {
  return Container(
    width: 250,
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
        )
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vertex Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        _buildDetailRow('ID:', '${vertex.id}'),
        _buildDetailRow('Tag:', vertex.tag),
        _buildDetailRow('Degree:', '${vertex.degree}'),
        _buildDetailRow('Position:', '(${vertex.position.x.toStringAsFixed(1)}, ${vertex.position.y.toStringAsFixed(1)})'),
        if (vertex.data != null) ...[
          SizedBox(height: 12),
          _buildDetailRow('Data:', '${vertex.data}'),
        ]
      ],
    ),
  );
};

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(value, overflow: TextOverflow.ellipsis),
        ),
      ],
    ),
  );
}
```

### Edge Panel on Hover

```dart
options.edgePanelBuilder = (edge) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edge Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Type: ${edge.edgeName}'),
        Text('From: ${edge.start.id}'),
        Text('To: ${edge.end?.id ?? 'N/A'}'),
        if (edge.data != null)
          Text('Data: ${edge.data}'),
      ],
    ),
  );
};
```

## Tap/Click Panel

```dart
options.onVertexTapUp = (vertex, event) {
  // Set panel to show
};

options.vertexTapUpPanel = Container(
  width: 400,
  height: 300,
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 10,
      )
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Full Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => options.hideVertexTapUpPanel(),
          ),
        ],
      ),
      Divider(),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection('General Info', [
                _buildField('ID', 'value1'),
                _buildField('Tag', 'value2'),
              ]),
              SizedBox(height: 16),
              _buildSection('Relationships', [
                _buildField('Incoming', '5'),
                _buildField('Outgoing', '3'),
              ]),
            ],
          ),
        ),
      ),
    ],
  ),
);
```

### Display Delay

```dart
// Panel appears after 500ms of hover
options.panelDelay = Duration(milliseconds: 500);
```

## Control Overlays Programmatically

```dart
// Hide all overlays
options.hideVerticalPanel();
options.hideHorizontalOverlay();
options.hideVertexTapUpPanel();

// Use in callbacks
options.onVertexTapUp = (vertex, event) {
  // Show custom panel
  // Hide others
  options.hideHorizontalOverlay();
};
```

## Further Reading

- [Options](options.md) - Panel configuration
- [Algorithms](algorithms.md) - Decorators with overlays
- [Models](models.md) - Vertex and Edge data

---

**Version:** 2.x | **License:** Apache 2.0
