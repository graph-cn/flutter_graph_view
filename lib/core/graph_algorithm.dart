// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Interface: point assignment algorithm of graph.
/// 接口：图的点位赋值算法
///
abstract class GraphAlgorithm {
  GraphAlgorithm? decorate;

  GraphAlgorithm(this.decorate);

  Size? size;

  Offset get center => Offset(size?.width ?? 0 / 2, size?.height ?? 0 / 2);

  double get offset => min(center.dx, center.dy) * 0.4;

  void compute(Vertex v, Graph graph);
}
