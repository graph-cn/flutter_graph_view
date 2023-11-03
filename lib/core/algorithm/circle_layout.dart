import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

class CircleLayout extends GraphAlgorithm {
  CircleLayout([decorator]) : super(decorator);

  @override
  void onGraphLoad(Graph graph) {
    var radius = max(center.dy, 100) * .8;
    var vertexes = graph.vertexes;
    for (var i = 0; i < vertexes.length; i++) {
      var vertex = vertexes[i];
      var angle = 2 * pi * i / vertexes.length;
      var x = sin(angle) * radius;
      var y = -cos(angle) * radius;

      vertex.position = Vector2(x + center.dx, y + center.dy);
    }
  }

  @override
  void compute(Vertex v, Graph graph) {
    // TODO: implement compute
  }
}
