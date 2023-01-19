// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flame/input.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Interface: point assignment algorithm of graph.
/// 接口：图的点位赋值算法
///
abstract class GraphAlgorithm {
  ///
  /// Algorithm decorate support.
  /// 定位算法的装饰器，可多个算法同时使用。
  ///
  GraphAlgorithm? decorate;

  ///
  ///
  GraphAlgorithm(this.decorate);

  /// Notify the size change event.
  ///
  /// 植入对容器尺寸的监听，用于捕捉窗口变化对画布产生的影响
  ValueNotifier<Size?> $size = ValueNotifier(null);

  ///
  /// Stage size.
  /// 图形展示的区域边界
  ///
  Size? get size => $size.value;

  /// Center of stage.
  /// 图形展示的中心点
  Offset get center => Offset(size?.width ?? 0 / 2, size?.height ?? 0 / 2);

  /// Nodes zoom offset from center.
  /// 节点区域相对中心点的偏移量。
  double get offset => min(center.dx, center.dy) * 0.4;

  ///
  /// Position setter.
  /// 对节点进行定位设值
  ///
  void compute(Vertex v, Graph graph);

  /// Vertexes will be reposition when they collided with another.
  ///
  /// 当节点发生碰撞时触发，从而对节点做重新定位。
  void repositionWhenCollision(Vertex me, Vertex another) {
    var thisCpn = me.cpn!;
    var position = me.cpn!.position;
    var other = another.cpn!;

    // Coordinate difference of collision point
    // 碰撞点的坐标差
    var dx = other.position.x - position.x;
    var dy = other.position.y - position.y;

    // When not activated by the mouse, stay away from each other
    // 当不被鼠标激活时，向着碰撞点相反的方向运动。
    if (!thisCpn.isHovered) {
      me.position.x = other.position.x - 2 * dx;
      me.position.y = other.position.y - 2 * dy;
    }
    if (!other.isHovered) {
      other.vertex.position.x = position.x + 2 * dx;
      other.vertex.position.y = position.y + 2 * dy;
    }
  }

  void onDrag(Vertex hoverVertex, DragUpdateInfo info) {
    var deltaPosition = info.delta.game;
    hoverVertex.position += deltaPosition;
    for (var neighbor in hoverVertex.neighbors) {
      if (neighbor.degree < hoverVertex.degree) {
        neighbor.position += deltaPosition;
      }
    }
  }

  void onZoomVertex(Vertex vertex, Vector2 pointLocation, double delta) {
    if (vertex.cpn?.isHovered ?? false) return;
    var vp = vertex.position;
    var zoomRate = delta > 0 ? 2 : -2; // delta > 0 缩小，delta < 0 放大
    var dx = (pointLocation.x - vp.x) / zoomRate;
    var dy = (pointLocation.y - vp.y) / zoomRate;
    vp.x += dx;
    vp.y += dy;
    vertex.radius -= zoomRate;
  }

  void onZoomEdge(Edge edge, Vector2 pointLocation, double delta) {}
}
