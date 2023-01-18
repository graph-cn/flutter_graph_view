// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// 图构建器
///
class GraphComponent extends FlameGame
    with
        HasTappableComponents,
        HasHoverables,
        PanDetector,
        HasCollisionDetection {
  dynamic data;
  late GraphAlgorithm algorithm;
  late DataConvertor convertor;
  BuildContext context;

  GraphComponent({
    required this.data,
    required this.algorithm,
    required this.context,
    required this.convertor,
  });

  late Graph graph;

  @override
  Future<void> onLoad() async {
    graph = convertor.convertGraph(data);
    graph.vertexes = graph.vertexes.toSet().toList()
      ..sort((key1, key2) => key1.degree - key2.degree > 0 ? -1 : 1);

    for (var edge in graph.edges) {
      add(EdgeComponent(edge, graph, context));
    }
    for (var vertex in graph.vertexes) {
      var vc = VertexComponent(vertex, graph, context, algorithm);
      vertex.cpn = vc;
      add(vc);
    }
  }

  /// Clear all vertexes' position value.
  ///
  /// 将所有点的位置清空，重新计算位置
  clearPosition() {
    for (var element in graph.vertexes) {
      element.position = Vector2.zero();
    }
  }
}
