// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Used to customize the vertex UI.
///
/// 用于自定义节点的UI。
abstract class VertexShape {
  VertexShape({this.decorators});
  List<VertexDecorator>? decorators;

  /// render the vertex shape to canvas by data.
  ///
  /// 通过节点数据将自定义的图形绘制到画布中。
  render(Vertex vertex, Canvas canvas, Paint paint, List<Paint> paintLayers);

  /// compute the width of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据来计算形状的宽，用于重叠与鼠标事件判断。
  double width(Vertex vertex);

  /// compute the height of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的高，用于重叠与鼠标事件判断。
  double height(Vertex vertex);

  /// compute the size of the shape from data, used for overlap and mouse event judgment.
  ///
  /// 通过数据计算形状的尺寸，用于重叠与鼠标事件判断。
  Vector2 size(Vertex vertex) {
    return Vector2(width(vertex), height(vertex));
  }

  /// create a hit box, used for overlap judgment.
  ///
  /// 创建一个碰撞容器，用于碰撞检测，解决重叠问题。
  ShapeHitbox hitBox(Vertex vertex, ShapeComponent cpn);

  /// update the attributes of hit box. Such as x, y, radius, etc.
  ///
  /// 更新碰撞容器的信息。宽、高、半径等
  void updateHitBox(Vertex vertex, ShapeHitbox hitBox);

  /// update the paint from data.
  ///
  /// 根据数据更新画笔属性。
  void setPaint(Vertex vertex);

  /// When some elements are activated and do not contain the current element.
  ///
  /// 当一些元素被激活且不包含当前元素
  bool isWeaken(Vertex vertex) {
    var cpn = vertex.cpn!;
    var graph = cpn.gameRef.graph;
    return (graph.hoverVertex != null &&
            (vertex != graph.hoverVertex &&
                !graph.hoverVertex!.neighbors.contains(vertex)) ||
        graph.hoverEdge != null &&
            !(graph.hoverEdge?.start == vertex ||
                graph.hoverEdge?.end == vertex));
  }

  VertexTextRenderer? textRenderer;
}
