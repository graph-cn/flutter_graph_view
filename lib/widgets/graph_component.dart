// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Boot of graph.
///
/// 图构建器
class GraphComponent extends FlameGame
    with HoverCallbacks, ScrollDetector, HasCollisionDetection, ScaleDetector {
  dynamic data;
  late GraphAlgorithm algorithm;
  late DataConvertor convertor;
  BuildContext context;
  late Options options;

  ValueNotifier<double> scale = ValueNotifier(1);
  // late final CameraComponent cameraComponent;
  int legendCount = 0;

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
    WidgetsBinding.instance.addPostFrameCallback((t) {
      var size = (context.findRenderObject() as RenderBox).size;
      algorithm.$size.value = Size(size.width, size.height);
      refreshData(data);
    });
  }

  void refreshData(data) {
    // ignore: invalid_use_of_internal_member
    world.children.clear();
    graph = convertor.convertGraph(data);
    graph.vertexes = graph.vertexes.toSet().toList()
      ..sort((key1, key2) => key1.degree - key2.degree > 0 ? -1 : 1);
    setDefaultVertexColor();
    algorithm.onGraphLoad(graph);

    graph.edges.forEach(_addEdge);
    graph.vertexes.forEach(_addVertex);

    options.graphStyle.graphColor(graph);
  }

  /// Add a vertex to the graph.
  ///
  /// 添加一个点到图中
  addVertex(vdata) {
    Vertex v = convertor.addVertex(vdata, graph);
    _addVertex(v);
  }

  /// Add an edge to the graph.
  ///
  /// 添加一条边到图中
  addEdge(edata) {
    Edge e = convertor.addEdge(edata, graph);
    _addEdge(e);
  }

  /// Merge the graph data.
  ///
  /// 合并图数据
  void mergeGraph(graphData) {
    var newGraph = convertor.convertGraph(graphData, graph: graph);
    newGraph.vertexes.forEach(_addVertex);
    newGraph.edges.forEach(_addEdge);
  }

  _addEdge(Edge edge) {
    var ec = EdgeComponent(edge, graph, context)..scaleNotifier = scale;
    if (edge.cpn == null) {
      edge.cpn = ec;
      world.add(ec);
    }
  }

  _addVertex(Vertex vertex) {
    if (vertex.cpn == null) {
      setDefaultVertexColor();
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
      algorithm.compute(vertex, graph);
      vertex.colors = options.graphStyle.vertexColors(vertex);
      createLegend();
    }
  }

  setDefaultVertexColor() {
    var tagColorByIndex = options.graphStyle.tagColorByIndex;
    var needCount = graph.allTags.length - tagColorByIndex.length;
    for (var i = tagColorByIndex.length; i < needCount; i++) {
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
  void onScaleUpdate(ScaleUpdateInfo info) {
    onPanUpdate(info.delta.global);
  }

  /// Global delta can be got from `ScaleDetector`.
  ///
  /// ```
  /// @override
  /// void onScaleUpdate(ScaleUpdateInfo info) {
  ///   onPanUpdate(info.delta.global);
  /// }
  /// ```
  ///
  /// Do NOT use `PanDetector` along with `ScaleDetector`.
  /// Otherwise, Scale will not work on mobile. Because Scale events are based on Pan events in Flutter.
  void onPanUpdate(Vector2 globalDelta) {
    if (graph.hoverVertex != null) {
      algorithm.onDrag(graph.hoverVertex!, globalDelta, camera.viewfinder);
      graph.hoverVertex?.cpn?.onDrag(globalDelta);
    } else {
      camera.viewfinder.position -= globalDelta / camera.viewfinder.zoom;
    }
  }

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom
        .clamp(options.scaleRange.x, options.scaleRange.y);
  }

  static const zoomPerScrollUnit = -0.05;

  @override
  void onScroll(PointerScrollInfo info) {
    var zoomCenter = info.eventPosition.widget;
    var zoomDelta = info.scrollDelta.global.y.sign * zoomPerScrollUnit;
    onZoom(zoomCenter: zoomCenter, zoomDelta: zoomDelta);
  }

  void onZoom({required Vector2 zoomCenter, double zoomDelta = 0}) {
    var vf = camera.viewfinder;
    var opg = vf.localToGlobal(Vector2.zero());
    var oz = vf.zoom;

    if (vf.zoom + zoomDelta > 0) {
      vf.zoom += zoomDelta;
    }
    clampZoom();

    if (vf.zoom <= options.scaleRange.x || vf.zoom >= options.scaleRange.y) {
      return;
    }
    keepMousePosition(null, opg, zoomDelta, vf, oz, zoomCenter);
  }

  /// ![](https://gitee.com/graph-cn/flutter_graph_view/raw/main/lib/widgets/GraphComponent_scale_explain.jpg)
  void keepMousePosition(
    PointerScrollInfo? info,
    Vector2 opg,
    double zoomDelta,
    Viewfinder vf,
    double oz, [
    Vector2? wp,
  ]) {
    assert(
      info != null || wp != null,
      'scroll info and widgetPosition cannot be null at the same time',
    );
    wp = wp ?? info!.eventPosition.widget;
    var wpg = wp - opg;
    var wpgDelta = wpg * zoomDelta;
    var npg = vf.localToGlobal(Vector2.zero());
    vf.position += (npg - opg + wpgDelta / oz) / vf.zoom;
  }

  void createLegend() {
    if (!options.useLegend) return;
    var graphStyle = options.graphStyle;
    for (var i = legendCount; i < graph.allTags.length; i++) {
      var tag = graph.allTags[i];

      add(
        RectangleComponent.fromRect(
          Rect.fromLTWH(40, 50.0 + 30 * i, 30, 18),
          paint: Paint()
            ..color = graphStyle.colorByTag(tag, graph.allTags) ??
                (i < graphStyle.tagColorByIndex.length
                    ? graphStyle.tagColorByIndex[i]
                    : graphStyle.defaultColor()[0]),
        ),
      );

      add(TextComponent(text: tag, position: Vector2(40 + 40, 44.0 + 30 * i)));

      legendCount = i;
    }
  }
}
