<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Styles and Colors

The styling system in Flutter Graph View gives you complete control over the visual appearance of your graph. From vertex colors and text styling to edge rendering and hover effects, every visual element can be customized to match your application's design language.

## GraphStyle

The main class for configuring all visual styles:

```dart
class GraphStyle {
  /// Map of colors by vertex tag (highest priority)
  /// Use this to assign specific colors to vertex types/categories
  Map<String, Color>? tagColor;
  
  /// List of colors by tag index (medium priority)
  /// Falls back to tagColorByIndex if tagColor doesn't have a match
  late List<Color> tagColorByIndex = [];
  
  /// Opacity of non-hovered/non-focused elements when hovering (0.0 to 1.0)
  /// Lower values create stronger visual focus on hovered element
  double hoverOpacity = 0.3;
  
  /// Default text style for vertex labels
  TextStyle? vertexTextStyle;
  
  /// Function to get text style dynamically per vertex
  /// Allows different text sizes/colors based on vertex properties
  VertexTextStyleGetter? vertexTextStyleGetter;
  
  /// Stroke (border) color around vertices
  Color? vertexStrokeColor;
  
  /// Stroke width in pixels
  double vertexStrokeWidth = 1.0;
  
  /// Default color for edges/connections
  Color edgeColor = const Color(0xFF888888);
  
  /// Stroke width for edges in pixels
  double edgeWidth = 1.0;
}
```

## Color System

### Priority Order

When determining a vertex color, the library checks in this order:

1. **tagColor** (Map<String, Color>) — Highest priority. If the vertex tag matches a key in this map, use that color.
2. **tagColorByIndex** (List<Color>) — Medium priority. If no tagColor match, use the color at the tag's index position in this list.
3. **Default/Random Color** — Lowest priority. If neither of the above provides a color, generate a random one for variety.

### Using tagColor (Dictionary Approach)

Explicitly map vertex types to colors:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..tagColor = {
      'user': Colors.blue,
      'admin': Colors.red,
      'bot': Colors.green,
      'developer': Colors.purple,
      'guest': Colors.grey,
    };
```

**Advantages:**
- Very readable and maintainable
- Easy to understand which color belongs to which type
- Perfect for semantic tagging (e.g., user roles)
- Supports dynamic color assignments per tag

### Using tagColorByIndex (Index Approach)

Assign colors by position in a list:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..tagColorByIndex = [
      Colors.red[400]!,
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.yellow[400]!,
      Colors.purple[400]!,
    ];
```

**Advantages:**
- Simple for small, numbered datasets
- Consistent, predictable ordering
- Good for auto-generated graphs with numeric tags

**When to use:** Data without semantic meaning, or when you have many auto-generated tags.

### Dynamic Colors

For advanced use cases, extend `GraphStyle` to compute colors based on vertex properties:

```dart
class DynamicGraphStyle extends GraphStyle {
  Map<String, Color> userPreferences = {};
  
  Color getVertexColor(Vertex vertex) {
    // Check user preferences first
    if (userPreferences.containsKey(vertex.tag)) {
      return userPreferences[vertex.tag]!;
    }
    
    // Fall back to default tag colors
    if (tagColor?.containsKey(vertex.tag) ?? false) {
      return tagColor![vertex.tag]!;
    }
    
    // Last resort: by index
    final index = int.tryParse(vertex.tag) ?? 0;
    if (index < tagColorByIndex.length) {
      return tagColorByIndex[index];
    }
    
    return Colors.grey;
  }
}
```

## Text Styling

### Static Text Style

Apply the same text style to all vertex labels:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..vertexTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
```

### Dynamic Text Style Per Vertex

Use a function to compute text style based on vertex properties:

```dart
typedef VertexTextStyleGetter = TextStyle? Function(
  Vertex vertex,
  VertexShape? shape,
);

final options = Options()
  ..graphStyle = GraphStyle()
    ..vertexTextStyleGetter = (vertex, shape) {
      // High-degree (hub) nodes get larger, bold text
      if (vertex.degree > 5) {
        return TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        );
      }
      
      // Low-degree nodes get smaller, lighter text
      return TextStyle(
        color: Colors.grey[300],
        fontSize: 10,
        fontWeight: FontWeight.normal,
      );
    };
```

**Example use cases:**
- Highlight important/central nodes with larger text
- Use color intensity based on node degree
- Dim text for leaf nodes, brighten for hubs

## Vertex Stroke (Border)

### Static Stroke

Add a border around all vertices:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..vertexStrokeColor = Colors.white
    ..vertexStrokeWidth = 2.0;
```

This creates a visible border/outline around each vertex, useful for:
- Creating visual separation between overlapping nodes
- Highlighting selected or important nodes
- Adding visual "pop" to the graph

### Dynamic Stroke

Change stroke color/width based on vertex state:

```dart
class InteractiveGraphStyle extends GraphStyle {
  Vertex? selectedVertex;
  
  @override
  Color? get vertexStrokeColor {
    // Bright stroke for selected vertices, subtle for others
    return selectedVertex != null ? Colors.yellow : Colors.white;
  }
  
  @override
  double get vertexStrokeWidth {
    // Thicker stroke for selected/important vertices
    return (selectedVertex?.isCenter ?? false) ? 3.0 : 1.0;
  }
}
```

## Edge Styling

### Color and Width

Configure edges globally:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..edgeColor = Colors.grey[600]!
    ..edgeWidth = 2.0;
```

### Color Per Edge Type

Assign different colors to different relationship types:

```dart
class TypedGraphStyle extends GraphStyle {
  Map<String, Color> edgeTypeColors = {
    'follows': Colors.blue,
    'manages': Colors.red,
    'collaborates': Colors.green,
    'owns': Colors.orange,
  };
  
  Color getEdgeColor(Edge edge) {
    return edgeTypeColors[edge.edgeName] ?? edgeColor;
  }
}
```

Then in your edge painter or rendering logic, call `getEdgeColor(edge)` to get the appropriate color.

### Dynamic Edge Width Based on Weight

```dart
class WeightedGraphStyle extends GraphStyle {
  double getEdgeWidth(Edge edge) {
    // Edges with higher weight are drawn thicker
    final weight = (edge.data as Map?)['weight'] ?? 1.0;
    return 1.0 + (weight * 0.5);  // Base 1.0 + weight factor
  }
}
```

## Hover Effects

### Hover Opacity

When a user hovers over a node or edge, reduce the opacity of non-hovered elements to create visual focus:

```dart
final options = Options()
  ..graphStyle = GraphStyle()
    ..hoverOpacity = 0.3;  // Non-hovered elements become 30% opaque
```

**Effect:** If you hover over a central hub node, all other nodes become dimmer, focusing attention on the selected node and its immediate connections.

**Typical values:**
- `0.2` — Very strong focus, other elements almost invisible
- `0.3` — Strong focus (default)
- `0.5` — Moderate focus, still see other elements clearly
- `0.7` or higher — Subtle effect, other elements remain visible

## Complete Styling Example

Here's a comprehensive example combining multiple styling techniques:

```dart
final graphStyle = GraphStyle()
  // Color by vertex type
  ..tagColor = {
    'important': Colors.red[600]!,
    'normal': Colors.blue[400]!,
    'inactive': Colors.grey[400]!,
  }
  
  // Text styling
  ..vertexTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  )
  
  // Borders
  ..vertexStrokeColor = Colors.white.withValues(alpha: 0.7)
  ..vertexStrokeWidth = 1.5
  
  // Edge styling
  ..edgeColor = Colors.grey[600]!
  ..edgeWidth = 1.2
  
  // Interaction feedback
  ..hoverOpacity = 0.35;

final options = Options()
  ..graphStyle = graphStyle
  ..backgroundBuilder = (context) => Container(
    color: Colors.grey[900],
  );
```

## Theme Integration

For apps with light/dark mode support:

```dart
GraphStyle getGraphStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  
  return GraphStyle()
    ..tagColor = {
      'user': isDark ? Colors.blue[300]! : Colors.blue[700]!,
      'admin': isDark ? Colors.red[300]! : Colors.red[700]!,
    }
    ..vertexTextStyle = TextStyle(
      color: isDark ? Colors.white : Colors.black,
      fontSize: 12,
    )
    ..edgeColor = isDark ? Colors.grey[600]! : Colors.grey[400]!
    ..hoverOpacity = isDark ? 0.25 : 0.4;
}
```

## Further Reading

- [Text Rendering](text_rendering.md) — Advanced label rendering options
- [Graph Options](options.md) — Additional configuration options
- [Quick Start](quick_start.md) — See styling in a working example

---

**Version:** 2.x | **License:** Apache 2.0
