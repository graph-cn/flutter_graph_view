// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Provide an external Api interface to pass in data and policy specification.
/// 提供一个对外Api接口，用来传入数据与策略指定（风格策略、布局策略）
///
class FlutterGraphView extends StatelessWidget {
  Set<Vertex> vertexes;
  Set<Edge> edges;
  late GraphAlgorithm algorithm;

  Set<dynamic> pickedIds = {};

  FlutterGraphView({
    Key? key,
    required this.vertexes,
    required this.edges,
    GraphAlgorithm? algorithm,
  }) : super(key: key) {
    this.algorithm = algorithm ?? ForceDirected();
  }

  addVertex() {}

  addEdge() {}

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: _GraphView(
          vertexes: vertexes,
          edges: edges,
          algorithm: algorithm,
          context: context),
    );
  }
}

///
/// 图构建器
///
class _GraphView extends FlameGame with HasTappableComponents, HasHoverables {
  Set<Vertex> vertexes;
  Set<Edge> edges;
  late GraphAlgorithm algorithm;
  BuildContext context;

  _GraphView({
    required this.vertexes,
    required this.edges,
    required this.algorithm,
    required this.context,
  });

  @override
  Future<void> onLoad() async {
    vertexes.forEach((element) {
      algorithm.compute(element, vertexes, edges);
    });
    edges.forEach((element) {
      add(EdgeComponent(element));
    });
    vertexes.forEach((vertex) {
      add(VertexComponent(vertex));
    });
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    removeFromParent();
  }
}
