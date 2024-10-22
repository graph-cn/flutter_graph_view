// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Used to customize the edge UI.
///
/// 用于自定义边的UI
abstract class EdgeShape {
  List<EdgeDecorator>? decorators;
  EdgeShape({this.decorators});

  /// render the edge shape to canvas by data.
  ///
  /// 通过边数据将自定义的图形绘制到画布中。
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers);

  /// compute the width of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据来计算形状的宽，用于重叠与鼠标事件判断。
  double width(Edge edge) {
    return len(edge);
  }

  /// compute the height of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的高，用于重叠与鼠标事件判断。
  double height(Edge edge);

  /// compute the size of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的尺寸，用于重叠与鼠标事件判断。
  Vector2 size(Edge edge) {
    return Vector2(width(edge), height(edge));
  }

  /// update the paint from data.
  ///
  /// 根据数据更新画笔属性。
  void setPaint(Edge edge);

  /// When some elements are activated and do not contain the current element.
  ///
  /// 当一些元素被激活且不包含当前元素
  bool isWeaken(Edge edge) {
    var graph = edge.cpn!.gameRef.graph;
    var isHoverVertexEdge = graph.hoverVertex != null &&
        !graph.hoverVertex!.neighborEdges.contains(edge);
    var isHoverEdge = graph.hoverEdge != null && graph.hoverEdge != edge;
    return isHoverVertexEdge || isHoverEdge;
  }

  /// Compute the line length by two vertex.
  ///
  /// 通过两个节点的坐标，计算线的长度。
  static double len(Edge edge) =>
      edge.end == null || edge.start.cpn == null || edge.end!.cpn == null
          ? 10
          : Util.distance(edge.start.cpn!.position, edge.end!.cpn!.position);

  /// Compute the shape angle by two vertex.
  ///
  /// 通过两个节点的坐标，获取线的旋转角度
  double angle(Edge edge) {
    Offset offset = Offset(
      (edge.end == null
              ? edge.start.cpn!.position.x
              : edge.end!.cpn!.position.x) -
          (edge.start.cpn!.position.x),
      (edge.end == null
              ? edge.start.cpn!.position.y
              : edge.end!.cpn!.position.y) -
          (edge.start.cpn!.position.y),
    );

    return offset.direction;
  }

  ShapeHitbox? hitBox(Edge edge, EdgeComponent edgeComponent);

  bool? hoverTest(Vector2 point, Edge edge, EdgeComponent edgeComponent) {
    return null;
  }
}
