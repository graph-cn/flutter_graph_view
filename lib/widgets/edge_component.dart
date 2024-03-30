// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
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
    with HasGameRef<GraphComponent>, TapCallbacks, HoverCallbacks {
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

  late final ShapeHitbox? hitBox;

  String get overlayName =>
      'edge${edge.start.id}-${edge.ranking}${edge.end != null ? "-${edge.end!.id}" : ''}';

  Duration get panelDelay =>
      gameRef.options.panelDelay ?? const Duration(milliseconds: 300);

  bool get hasPanel => gameRef.options.edgePanelBuilder != null;

  @override
  FutureOr<void> onLoad() {
    hitBox = edgeShape.hitBox(edge, this);
    if (hitBox != null) add(hitBox!);
    loadOverlay();
    return super.onLoad();
  }

  void loadOverlay() {
    var panelBuilder = gameRef.options.edgePanelBuilder;
    if (!hasPanel) return;

    gameRef.overlays.addEntry(overlayName, (_, game) {
      return panelBuilder!(edge, gameRef.camera.viewfinder);
    });
  }

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
  void onHoverEnter() {
    paint.strokeWidth = 4;
    hitBox?.width = 4;
    gameRef.graph.hoverEdge = edge;
    if (hasPanel) {
      gameRef.overlays.add(overlayName);
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    var hover = edgeShape.hoverTest(point, edge, this);
    if (hover == null) return super.containsLocalPoint(point);
    return hover;
  }

  /// Change the line to its original width ater mouse exists.
  /// 当鼠标浮出时，将线变回原来的宽度。
  @override
  void onHoverExit() {
    paint.strokeWidth = 1;
    hitBox?.width = 1;
    gameRef.graph.hoverEdge = null;
    if (hasPanel) {
      Future.delayed(panelDelay, () {
        gameRef.overlays.remove(overlayName);
      });
    }
  }
}
