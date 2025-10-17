// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

class NothingEdgeShape extends EdgeShape {
  @override
  double height(Edge edge) {
    return 0;
  }

  @override
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers) {}

  @override
  Paint getPaint(Edge edge) {
    return Paint();
  }
}

class NothingShape extends VertexShape {
  @override
  double height(Vertex vertex) {
    return (vertex.size?.toVector2().x ?? 0.0) / 2;
  }

  @override
  double width(Vertex vertex) {
    return (vertex.size?.toVector2().y ?? 0.0) / 2;
  }

  @override
  render(Vertex vertex, Canvas canvas, Paint paint, List<Paint> paintLayers) {}

  @override
  Paint getPaint(Vertex vertex) {
    // TODO: implement setPaint
    return Paint();
  }
}
