// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

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
  List<GraphAlgorithm>? decorators;

  GraphAlgorithm? rootAlg;

  Widget Function()? horizontalOverlay;
  Widget Function()? verticalOverlay;
  Widget Function()? leftOverlay;
  Graph? graph;

  List<Widget>? horizontalOverlays({
    required GraphAlgorithm rootAlg,
    required Graph graph,
  }) {
    return [
      if (horizontalOverlay != null) horizontalOverlay!(),
      if (decorators != null)
        ...decorators!
            .where((alg) => alg.horizontalOverlay != null)
            .map((ob) => ob.horizontalOverlay!())
            .toList(),
    ];
  }

  void hideVerticalOverlay() {
    graph?.options?.hideVerticalPanel();
  }

  void hideHorizontalOverlay() {
    graph?.options?.hideHorizontalOverlay();
  }

  void hideVertexTapUpOverlay() {
    graph?.options?.hideVertexTapUpPanel();
  }

  List<Widget>? verticalOverlays({
    required GraphAlgorithm rootAlg,
    required Graph graph,
  }) {
    return [
      if (verticalOverlay != null) verticalOverlay!(),
      if (decorators != null)
        ...decorators!
            .where((alg) => alg.verticalOverlay != null)
            .map((ob) => ob.verticalOverlay!())
            .toList(),
    ];
  }

  List<Widget>? leftOverlays({
    required GraphAlgorithm rootAlg,
    required Graph graph,
  }) {
    return [
      if (leftOverlay != null) leftOverlay!(),
      if (decorators != null)
        ...decorators!
            .where((alg) => alg.leftOverlay != null)
            .map((ob) => ob.leftOverlay!())
            .toList(),
    ];
  }

  setGlobalData({
    required GraphAlgorithm rootAlg,
    required Graph graph,
  }) {
    this.rootAlg = rootAlg;
    this.graph = graph;
    decorators?.forEach((element) {
      element.setGlobalData(rootAlg: rootAlg, graph: graph);
    });
  }

  ///
  ///
  GraphAlgorithm({this.decorators});

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
  Offset get center => Offset((size?.width ?? 0) / 2, (size?.height ?? 0) / 2);

  @mustCallSuper
  void afterDrag(Vertex vertex, Vector2 globalDelta) {
    for (GraphAlgorithm decorator in decorators ?? []) {
      decorator.afterDrag(vertex, globalDelta);
    }
  }

  @mustCallSuper
  beforeMerge(dynamic data) {
    for (GraphAlgorithm decorator in decorators ?? []) {
      decorator.beforeMerge(data);
    }
  }

  @mustCallSuper
  void beforeLoad(data) {
    for (GraphAlgorithm decorator in decorators ?? []) {
      decorator.beforeLoad(data);
    }
  }

  void onGraphLoad(Graph graph) {
    beforeLoad(graph.data);
    for (var v in graph.vertexes) {
      onLoad(v);
    }
  }

  /// Nodes zoom offset from center.
  /// 节点区域相对中心点的偏移量。
  double get offset => min(center.dx, center.dy) * 0.4;

  /// Position setter.
  ///
  /// 对节点进行定位设值
  @mustCallSuper
  void compute(Vertex v, Graph graph) {
    if (decorators != null) {
      for (var decorator in decorators!) {
        if (!decorator.needContinue(v)) return;
        decorator.compute(v, graph);
      }
    }
  }

  bool needContinue(Vertex v) {
    return true;
  }

  /// Called when the graph is loaded.
  @mustCallSuper
  void onLoad(Vertex v) {
    if (decorators != null) {
      for (var decorator in decorators!) {
        decorator.onLoad(v);
      }
    }
  }

  void onDrag(Vertex? hoverVertex, Vector2 globalDelta) {
    if (hoverVertex == null) return;
    var zoom = graph?.options?.scale.value ?? 1;
    var delta = globalDelta / zoom;
    hoverVertex.position += delta;
    for (var neighbor in hoverVertex.neighbors) {
      if (neighbor.degree < hoverVertex.degree) {
        neighbor.position += delta;
      }
    }
    afterDrag(hoverVertex, globalDelta);
  }

  void onZoomEdge(Edge edge, Vector2 pointLocation, double delta) {}
}
