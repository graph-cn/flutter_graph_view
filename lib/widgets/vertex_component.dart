// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Flame Component.
/// Used to handle the presentation and interaction of node
///
/// 引擎组件
/// 用于处理节点的展示与交互
///
class VertexComponent extends CircleComponent
    with TapCallbacks, Hoverable, HasGameRef {
  late Vertex vertex;
  ValueNotifier<double>? scaleNotifier;
  static const speed = 3;
  Graph graph;
  BuildContext context;
  GraphAlgorithm algorithm;

  VertexComponent(this.vertex, this.graph, this.context, this.algorithm)
      : super(
          position: vertex.position,
          radius: vertex.radius,
          anchor: Anchor.center,
        );
  int count = 0;
  double offsetX = 0;
  double offsetY = 0;

  bool breathDirect = false;

  @override
  Future<void> onLoad() {
    breathDirect = math.Random().nextBool();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);

    // TODO 移到 Style Config
    {
      algorithm.compute(vertex, graph);
      // radius = vertex.radius = math.log(vertex.degree * 10 + 1) * 3 + 5;
      if (graph.hoverVertex != null && vertex != graph.hoverVertex) {
        paint = Paint()
          ..shader = ui.Gradient.radial(
            Offset(vertex.radius, vertex.radius),
            vertex.radius,
            List.generate(
              vertex.colors.length,
              (index) => vertex.colors[index].withOpacity(.2),
            ),
          );
      } else {
        paint = Paint()
          ..shader = ui.Gradient.radial(
            Offset(vertex.radius, vertex.radius),
            vertex.radius,
            vertex.colors,
          );
      }
    }

    // TODO 移到 Layout 中
    {
      if (count % 150 == 0) {
        breathDirect = !breathDirect;
        offsetY = (breathDirect ? 1 : -1) * .1;
      }
      // offsetX =
      //     (math.Random().nextBool() ? 1 : -1) * math.Random().nextDouble() * .8;

      if (vertex != graph.hoverVertex) {
        vertex.position.x += offsetX;
        vertex.position.y += offsetY;
      }
    }

    position = vertex.position;
    double scaleV = scaleNotifier?.value ?? 1.0;
    scale = Vector2(scaleV, scaleV);
    angle += speed * dt * (isHovered ? 0 : 3);
    angle %= 2 * math.pi;
    count++;
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    info.handled = true;
    graph.hoverVertex = vertex;
    return super.onHoverEnter(info);
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    info.handled = false;
    graph.hoverVertex = null;
    return super.onHoverLeave(info);
  }

  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}
