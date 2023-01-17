// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/palette.dart';
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

  EdgeComponent(this.edge)
      : super(
          position: edge.start.position,
          anchor: Anchor.centerLeft,
          paint: BasicPalette.white.paint(),
        );

  double len() => math.sqrt(
        math.pow((edge.start.position.x) - (edge.end.position.x), 2) +
            math.pow((edge.end.position.y) - (edge.start.position.y), 2),
      );

  @override
  onLoad() {
    super.onLoad();
    size = Vector2(len().toDouble(), strokeWidth);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position = edge.start.position;
    size = Vector2(len().toDouble(), strokeWidth);
    Offset offset = Offset(
      (edge.end.position.x) - (edge.start.position.x),
      (edge.end.position.y) - (edge.start.position.y),
    );

    angle = offset.direction;
  }

  bool onHoverEnter(PointerHoverInfo info) {
    strokeWidth = 4;
    return true;
  }

  bool onHoverLeave(PointerHoverInfo info) {
    strokeWidth = 2;
    return true;
  }
}
