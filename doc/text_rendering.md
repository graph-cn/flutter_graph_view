<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
  This source code is licensed under Apache 2.0 License.
 -->

# Text Rendering

Implement custom text rendering strategies for vertex labels. This document covers the `VertexTextRenderer` interface and advanced rendering patterns beyond the default implementation.

> **Note:** For basic text styling (colors, fonts), see [Styles](styles.md). This document focuses on custom rendering implementations.

## VertexTextRenderer Interface

The `VertexTextRenderer` interface defines the contract for rendering text on vertices:

```dart
abstract class VertexTextRenderer {
  /// Draw text at the vertex position
  /// 
  /// Parameters:
  /// - canvas: The drawing surface
  /// - vertex: The vertex being rendered
  /// - text: The text content to render
  /// - style: The TextStyle to apply (from Options or computed dynamically)
  void draw(
    Canvas canvas,
    Vertex vertex,
    String text,
    TextStyle? style,
  );
}
```

### Dynamic Text Styling

For text color and font styling, see [Styles](styles.md):

```dart
// Static style
options.graphStyle.vertexTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 12,
  fontWeight: FontWeight.bold,
);

// Dynamic style per vertex
options.graphStyle.vertexTextStyleGetter = (vertex, shape) {
  // Hub nodes: larger, bolder text
  if (vertex.degree > 5) {
    return TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );
  }
  // Regular nodes: smaller, lighter text
  return TextStyle(
    color: Colors.grey[300],
    fontSize: 10,
  );
};
```

## Rendering Performance Tips

1. **Cache TextPainter:** If rendering the same text repeatedly, cache the TextPainter to avoid relayout
   
   ```dart
   final textCache = <String, TextPainter>{};
   
   TextPainter getCachedPainter(String text, TextStyle? style) {
     return textCache.putIfAbsent(text, () {
       final painter = TextPainter(
         text: TextSpan(text: text, style: style),
         textDirection: TextDirection.ltr,
       );
       painter.layout();
       return painter;
     });
   }
   ```

2. **Disable text for small vertices:** Hide text when zoom is very small
   
   ```dart
   void draw(Canvas canvas, Vertex vertex, String text, TextStyle? style) {
     // Skip text if vertex is smaller than 20px
     if (vertex.radiusZoom < 20) return;
     
     // ... render text
   }
   ```

3. **Use simple styles:** Avoid complex text styles (multiple shadows, gradients) in custom renderers

4. **Batch rendering:** If you have many custom text positions, calculate all positions before drawing

## Further Reading

- [Styles](styles.md) — Text color and font configuration
- [Options](options.md) — General text configuration (showText, textGetter)
- [Models](models.md) — Vertex properties and data structure

---

**Version:** 2.x | **License:** Apache 2.0
