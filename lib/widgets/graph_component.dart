// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/src/events/messages/pointer_move_event.dart' as pme;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Boot of graph.
///
/// 图构建器
class GraphComponent extends FlameGame
    with
        PanDetector,
        HoverCallbacks,
        PanDetector,
        ScrollDetector,
        HasCollisionDetection,
        ScaleDetector {
  dynamic data;
  late GraphAlgorithm algorithm;
  late DataConvertor convertor;
  BuildContext context;
  late Options options;

  ValueNotifier<double> scale = ValueNotifier(1);
  Vector2? pointLocation;
  // late final CameraComponent cameraComponent;

  GraphComponent({
    required this.data,
    required this.algorithm,
    required this.context,
    required this.convertor,
    Options? options,
  }) {
    super.camera = CameraComponent(world: world)..ancestors(includeSelf: true);
    this.options = options ?? Options();
  }

  late Graph graph;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    refreshData(data);
  }

  void refreshData(data) {
    // ignore: invalid_use_of_internal_member
    // world.children.clear();
    graph = convertor.convertGraph(data);
    graph.vertexes = graph.vertexes.toSet().toList()
      ..sort((key1, key2) => key1.degree - key2.degree > 0 ? -1 : 1);
    setDefaultVertexColor();
    for (var edge in graph.edges) {
      var ec = EdgeComponent(edge, graph, context)..scaleNotifier = scale;
      edge.cpn = ec;
      world.add(ec);
    }
    for (var vertex in graph.vertexes) {
      var vc = VertexComponent(
        vertex,
        graph,
        context,
        algorithm,
        options: options,
        graphComponent: this,
      )..scaleNotifier = scale;
      vertex.cpn = vc;
      world.add(vc);
    }

    createLegend();
    options.graphStyle.graphColor(graph);
  }

  setDefaultVertexColor() {
    var tagColorByIndex = options.graphStyle.tagColorByIndex;
    var needCount = graph.allTags.length - tagColorByIndex.length;
    for (var i = 0; i < needCount; i++) {
      tagColorByIndex.add(options.graphStyle.defaultColor()[0]);
    }
  }

  updateViewport(x, y) {
    camera.viewport.size = Vector2(x, y);
  }

  /// Clear all vertexes' position value.
  ///
  /// 将所有点的位置清空，重新计算位置
  clearPosition() {
    for (var element in graph.vertexes) {
      element.position = Vector2.zero();
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (graph.hoverVertex != null) {
      algorithm.onDrag(graph.hoverVertex!, info, camera.viewfinder);
    } else {
      camera.viewfinder.position -= info.delta.global / camera.viewfinder.zoom;
    }
  }

  @override
  void onPointerMove(pme.PointerMoveEvent event) {
    super.onPointerMove(event);
    pointLocation = event.localPosition;
  }

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 3.0);
  }

  static const zoomPerScrollUnit = -0.05;

  @override
  void onScroll(PointerScrollInfo info) {
    var wp = info.eventPosition.widget;
    var zoomDelta = info.scrollDelta.global.y.sign * zoomPerScrollUnit;
    camera.viewfinder.zoom += zoomDelta;

    clampZoom();

    var zoom = camera.viewfinder.zoom;
    var delta = 1 - zoom;
    var wpDelta = wp * delta;
    camera.viewfinder.position = camera.viewfinder.globalToLocal(
        camera.viewfinder.localToGlobal(Vector2.zero()) - wpDelta);
  }

  void createLegend() {
    if (!options.useLegend) return;
    var graphStyle = options.graphStyle;
    for (var i = 0; i < graph.allTags.length; i++) {
      var tag = graph.allTags[i];

      add(
        RectangleComponent.fromRect(
          Rect.fromLTWH(40, 50.0 + 30 * i, 30, 18),
          paint: Paint()..color = graphStyle.colorByTag(tag, graph.allTags)!,
        ),
      );

      add(TextComponent(text: tag, position: Vector2(40 + 40, 44.0 + 30 * i)));
    }
  }
}
