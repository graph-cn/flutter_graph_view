// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'dart:math' as math;

///
/// Flame Component.
/// Logic used to handle the connecting line between nodes (display & interaction)
///
/// 引擎组件
/// 用于处理节点之间连接线的逻辑（展示+交互）
///
class EdgeComponent extends RectangleComponent with TapCallbacks, Hoverable {
  late final Edge edge;
  ValueNotifier<double>? scaleNotifier;
  double strokeWidth = 2;
  Graph graph;
  BuildContext context;

  EdgeComponent(this.edge, this.graph, this.context)
      : super(
          position: edge.start.position,
          anchor: Anchor.centerLeft,
        );

  /// Compute the line length by two vertex.
  /// 通过两个节点的坐标，计算线的长度。
  double len() => edge.end == null
      ? 10
      : math.sqrt(
          math.pow((edge.start.position.x) - (edge.end!.position.x), 2) +
              math.pow((edge.end!.position.y) - (edge.start.position.y), 2),
        );

  @override
  onLoad() {
    super.onLoad();
    size = Vector2(len().toDouble(), strokeWidth);
  }

  /// Update edge display by data of `edge`.
  /// 根据节点数据，对界面进行更新
  @override
  void update(double dt) {
    super.update(dt);
    position = edge.start.position;
    size = Vector2(len().toDouble(), strokeWidth);
    if (graph.hoverVertex != null && graph.hoverVertex != edge.start) {
      paint = Paint()..color = Colors.white10;
    } else {
      paint = Paint()..color = Colors.white;
    }
    Offset offset = Offset(
      (edge.end == null ? edge.start.position.x : edge.end!.position.x) -
          (edge.start.position.x),
      (edge.end == null ? edge.start.position.y : edge.end!.position.y) -
          (edge.start.position.y),
    );

    angle = offset.direction;
  }

  /// Line will be wider after mouse enter.
  /// 对被鼠标浮入的线增加显视宽度
  @override
  bool onHoverEnter(PointerHoverInfo info) {
    strokeWidth = 4;
    return true;
  }

  /// Change the line to its original width ater mouse exists.
  /// 当鼠标浮出时，将线变回原来的宽度。
  @override
  bool onHoverLeave(PointerHoverInfo info) {
    strokeWidth = 2;
    return true;
  }
}
