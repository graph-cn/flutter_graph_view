// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:typed_data' show Float64List;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' show ValueNotifier;
import 'package:flutter_graph_view/flutter_graph_view.dart';

class GraphPainter extends CustomPainter {
  final Graph graph;
  GraphPainter(this.graph);

  List<Vertex> get vertexes => graph.vertexes;
  List<Edge> get edges => graph.edges.toList();

  ValueNotifier<double> get scale => options.scale;
  ValueNotifier<Offset> get offset => options.offset;
  Options get options => graph.options!;
  Vector2 get p => options.pointer;

  @override
  void paint(Canvas canvas, Size size) {
    options.size.value = size;
    var edgeUnhoverCount = 0;
    // 绘制边
    for (Edge edge in edges) {
      if (!edge.visible || !edge.start.visible || (edge.end?.visible != true)) {
        continue;
      }
      Vertex? target = edge.end;
      if (target != null) {
        canvas.save();
        var shape = graph.options!.edgeShape;
        var p = shape.getPaint(edge);
        var transformMatrix = shape.transformMatrix(edge, p);
        canvas
            .transform(Float64List.fromList(transformMatrix.storage.toList()));
        graph.options?.edgeShape.render(edge, canvas, p, []);
        canvas.restore();
        if (shape.hoverTest(this.p, edge, transformMatrix, p.strokeWidth) ==
                true &&
            graph.hoverVertex == null) {
          graph.hoverEdge = edge;
        } else {
          edgeUnhoverCount++;
        }
      }
    }
    if (edgeUnhoverCount == edges.length) graph.hoverEdge = null;

    var unhoverCount = 0;
    // 绘制节点
    for (Vertex vertex in vertexes) {
      if (!vertex.visible) continue;
      if (vertex.isHovered) {
        graph.hoverVertex = vertex;
      } else {
        unhoverCount++;
      }
      canvas.save();
      canvas.translate(vertex.position.x - (vertex.size?.width ?? 0) / 2,
          vertex.position.y - (vertex.size?.height ?? 0) / 2);
      graph.options?.vertexShape.render(
          vertex, canvas, graph.options!.vertexShape.getPaint(vertex), []);
      canvas.restore();
    }
    if (unhoverCount == vertexes.length) graph.hoverVertex = null;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
