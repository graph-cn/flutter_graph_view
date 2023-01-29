// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Flame Component.
/// Logic used to handle the connecting line between nodes (display & interaction)
///
/// 引擎组件
/// 用于处理节点之间连接线的逻辑（展示+交互）
///
class EdgeComponent extends ShapeComponent
    with HasGameRef<GraphComponent>, TapCallbacks, Hoverable {
  late final Edge edge;
  late ValueNotifier<double> scaleNotifier;
  Graph graph;
  BuildContext context;

  EdgeComponent(this.edge, this.graph, this.context)
      : super(
          position: edge.start.position,
          anchor: Anchor.centerLeft,
        );

  EdgeShape get edgeShape => gameRef.options.edgeShape;

  @override
  void render(Canvas canvas) =>
      edgeShape.render(edge, canvas, paint, paintLayers);

  /// Update edge display by data of `edge`.
  /// 根据节点数据，对界面进行更新
  @override
  void update(double dt) {
    super.update(dt);
    position = edge.start.cpn!.position;
    size = edgeShape.size(edge);
    angle = edgeShape.angle(edge);
    edgeShape.setPaint(edge);
  }

  /// Line will be wider after mouse enter.
  /// 对被鼠标浮入的线增加显视宽度
  @override
  bool onHoverEnter(PointerHoverInfo info) {
    paint.strokeWidth = 4;
    gameRef.graph.hoverEdge = edge;
    gameRef.overlays.add('edge');
    return true;
  }

  /// Change the line to its original width ater mouse exists.
  /// 当鼠标浮出时，将线变回原来的宽度。
  @override
  bool onHoverLeave(PointerHoverInfo info) {
    paint.strokeWidth = 1;
    gameRef.graph.hoverEdge = null;
    Future.delayed(const Duration(milliseconds: 300), () {
      gameRef.overlays.remove('edge');
    });
    return true;
  }
}
