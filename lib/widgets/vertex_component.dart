// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Flame Component: Used to handle the presentation and interaction of node
///
/// 引擎组件：用于处理节点的展示与交互
class VertexComponent extends ShapeComponent
    with
        TapCallbacks,
        HoverCallbacks,
        HasGameRef<GraphComponent>,
        CollisionCallbacks
    implements SizeProvider {
  late Vertex vertex;
  late ValueNotifier<double> scaleNotifier;
  static const speed = 20;
  Graph graph;
  BuildContext context;
  GraphAlgorithm algorithm;
  Options? options;
  GraphComponent? graphComponent;
  ShapeHitbox? hitBox;

  VertexComponent(
    this.vertex,
    this.graph,
    this.context,
    this.algorithm, {
    this.options,
    this.graphComponent,
  }) : super(
          position: vertex.position,
          anchor: Anchor.center,
          priority: 1,
        );

  final Map<String, dynamic> properties = {};

  bool collisionEnable = false;

  String get overlayName => 'vertex${vertex.id}';

  Duration get panelDelay =>
      gameRef.options.panelDelay ?? const Duration(milliseconds: 300);

  bool get hasPanel => gameRef.options.vertexPanelBuilder != null;

  @override
  FutureOr<void> onLoad() {
    if (options?.enableHit != false) {
      add(hitBox = vertexShape.hitBox(vertex, this));
    }
    algorithmOnLoad(algorithm);
    loadOverlay();
    return super.onLoad();
  }

  void loadOverlay() {
    var panelBuilder = gameRef.options.vertexPanelBuilder;
    if (!hasPanel) return;

    gameRef.overlays.addEntry(overlayName, (_, game) {
      return panelBuilder!(vertex, gameRef.camera.viewfinder);
    });
  }

  /// Recursively call the onLoad method of the algorithm,
  ///   assign values to the parameters of each algorithm
  /// 递归调用算法的onLoad方法，为各个算法的参数赋值
  void algorithmOnLoad(GraphAlgorithm? algorithm) {
    if (algorithm == null) return;
    algorithm.onLoad(vertex);
  }

  /// Recursively call the compute method of the algorithm,
  ///  and then call the compute method of the next algorithm
  /// 递归调用算法的compute方法，然后调用下一个算法的compute方法
  void algorithmCompute(GraphAlgorithm? algorithm) {
    if (algorithm == null) return;
    algorithm.compute(vertex, graph);
  }

  @override
  void render(Canvas canvas) =>
      vertexShape.render(vertex, canvas, paint, paintLayers);

  VertexShape get vertexShape => gameRef.options.vertexShape;

  @override
  void update(double dt) {
    super.update(dt);
    size = vertexShape.size(vertex);
    algorithm.$size.value = Size(gameRef.size.x, gameRef.size.y);

    algorithmCompute(algorithm);
    hitBox?.position = position;
    if (hitBox != null) vertexShape.updateHitBox(vertex, hitBox!);
    vertexShape.setPaint(vertex);

    position.x = vertex.position.x;
    position.y = vertex.position.y;
    if (Util.distance(position, vertex.position) < 1 && !collisionEnable) {
      collisionEnable = true;
    }
  }

  @override
  void onHoverEnter() {
    graph.hoverVertex = vertex;
    if (hasPanel) {
      Future.delayed(panelDelay, () {
        if (isHovered) {
          gameRef.overlays.add(overlayName);
        }
      });
    }
  }

  @override
  void onHoverExit() {
    graph.hoverVertex = null;
    if (hasPanel) {
      Future.delayed(panelDelay, () {
        gameRef.overlays.remove(overlayName);
      });
    }
  }

  @mustCallSuper
  void onDrag(Vector2 globalDelta) {
    if (hasPanel) {
      gameRef.overlays.remove(overlayName);
      gameRef.overlays.add(overlayName);
    }
    algorithm.afterDrag(vertex, globalDelta);
  }

  @override
  void onTapDown(TapDownEvent event) {
    options?.onVertexTapDown?.call(vertex, event);
    event.handled = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    var graphData = options?.onVertexTapUp?.call(vertex, event);
    _refresh(graphData);
    event.handled = true;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    options?.onVertexTapCancel?.call(vertex, event);
    event.handled = true;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is VertexComponent && collisionEnable && this != other) {
      algorithm.repositionWhenCollision(vertex, other.vertex);
    }
  }

  void _refresh(graphData) {
    if (graphData != null) {
      // refresh data
      graphComponent?.refreshData(graphData);
    }
  }

  String? displayName() {
    var txt = gameRef.options.textGetter.call(vertex);
    return '${vertex.id}${txt != vertex.id ? " ($txt) " : ""}';
  }
}
