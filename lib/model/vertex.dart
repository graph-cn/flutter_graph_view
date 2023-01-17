// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of vertex component.
/// 节点组件的数据模型
///
class Vertex<I> {
  late I id;
  late String tag;
  List<String>? tags;

  Set<Edge> nextEdges = {};
  Set<Vertex<I>> nextVertexes = {};
  Set<Vertex<I>> prevVertexes = {};

  int degree = 0;

  bool hover = false;

  bool picked = false;

  late List<Color> colors = [
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
  ];

  Vector2 position = Vector2(0, 0);

  late dynamic data;

  late double radius = 10;

  Vertex();
}
