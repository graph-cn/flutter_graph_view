// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Flame Component: Used to handle the presentation and interaction of node
///
/// 引擎组件：用于处理节点的展示与交互
class VertexComponent extends ShapeComponent
    with
        TapCallbacks,
        Hoverable,
        HasGameRef<GraphComponent>,
        CollisionCallbacks {
  late Vertex vertex;
  late ValueNotifier<double> scaleNotifier;
  static const speed = 20;
  Graph graph;
  BuildContext context;
  GraphAlgorithm algorithm;

  VertexComponent(this.vertex, this.graph, this.context, this.algorithm)
      : super(
          position: vertex.position,
          anchor: Anchor.center,
        );

  final Map<String, dynamic> properties = {};

  bool collisionEnable = false;
  late final ShapeHitbox hitBox;

  @override
  FutureOr<void> onLoad() {
    add(hitBox = vertexShape.hitBox(vertex, this));
    algorithmOnLoad(algorithm);
    return super.onLoad();
  }

  /// Recursively call the onLoad method of the algorithm,
  ///   assign values to the parameters of each algorithm
  /// 递归调用算法的onLoad方法，为各个算法的参数赋值
  void algorithmOnLoad(GraphAlgorithm? algorithm) {
    if (algorithm == null) return;
    algorithm.onLoad(vertex);
    algorithmOnLoad(algorithm.decorator);
  }

  /// Recursively call the compute method of the algorithm,
  ///  and then call the compute method of the next algorithm
  /// 递归调用算法的compute方法，然后调用下一个算法的compute方法
  void algorithmCompute(GraphAlgorithm? algorithm) {
    if (algorithm == null) return;
    algorithm.compute(vertex, graph);
    algorithmCompute(algorithm.decorator);
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
    hitBox.position = position;
    vertexShape.updateHitBox(vertex, hitBox);
    vertexShape.setPaint(vertex);

    position.x += (vertex.position.x - position.x) * dt * speed;
    position.y += (vertex.position.y - position.y) * dt * speed;
    if (Util.distance(position, vertex.position) < 1 && !collisionEnable) {
      collisionEnable = true;
    }
  }

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    info.handled = true;
    graph.hoverVertex = vertex;
    gameRef.overlays.add('vertex');
    return super.onHoverEnter(info);
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    info.handled = false;
    graph.hoverVertex = null;
    Future.delayed(const Duration(milliseconds: 300), () {
      gameRef.overlays.remove('vertex');
    });
    return super.onHoverLeave(info);
  }

  @override
  void onTapDown(TapDownEvent event) {
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
}
