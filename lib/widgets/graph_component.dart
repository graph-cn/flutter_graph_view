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
    this.options.pause.addListener(pause);
    pause();
  }

  late Graph graph;

  @override
  Future<void> onLoad() async {
    algorithm.beforeLoad(data);
    camera.viewfinder.anchor = Anchor.topLeft;
    WidgetsBinding.instance.addPostFrameCallback((t) {
      var size = (context.findRenderObject() as RenderBox).size;
      algorithm.$size.value = Size(size.width, size.height);
      addControllerOverlays(size);
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
  void mergeGraph(graphData, {bool manual = true}) {
    if (manual) algorithm.beforeMerge(graphData);
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
      var vc = options.vertexComponentNew.call(
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

      var legendColor = graphStyle.colorByTag(tag, graph.allTags) ??
          (i < graphStyle.tagColorByIndex.length
              ? graphStyle.tagColorByIndex[i]
              : graphStyle.defaultColor()[0]);

      // add legend
      // 添加图例
      var legendItem = options.legendBuilder(legendColor, i);
      add(legendItem);

      // add legend text
      // 添加图例文字
      var legendText =
          options.legendTextBuilder(tag, i, legendColor, legendItem.position);
      add(legendText);

      legendCount = i;
    }
  }

  void addControllerOverlays(Size size) {
    addHorizontalOverlays(size);
    addVerticalOverlays(size);
    addVertexTapUpPanel(size);
    addLegendOverlays(size);
  }

  void showVertexTapUpPanel() {
    if (overlays.activeOverlays.contains('verticalController')) {
      overlays.remove('verticalController');
    }
    overlays.add('vertexTapUpPanel');
  }

  void hideVertexTapUpPanel() {
    if (overlays.activeOverlays.contains('vertexTapUpPanel')) {
      overlays.remove('vertexTapUpPanel');
    }
  }

  void addHorizontalOverlays(Size size) {
    overlays.addEntry('horizontalController', (_, game) {
      return Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: size.width,
                maxHeight: options.horizontalControllerHeight,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...(algorithm.horizontalOverlays(
                          world: world,
                          rootAlg: algorithm,
                          graphComponent: this,
                        ) ??
                        []),
                    if (algorithm
                            .verticalOverlays(
                                world: world,
                                rootAlg: algorithm,
                                graphComponent: this)
                            ?.isNotEmpty ==
                        true)
                      IconButton(
                        onPressed: () {
                          if (overlays.activeOverlays
                              .contains('verticalController')) {
                            overlays.remove('verticalController');
                          } else {
                            if (overlays.activeOverlays
                                .contains('vertexTapUpPanel')) {
                              overlays.remove('vertexTapUpPanel');
                            }
                            overlays.add('verticalController');
                          }
                        },
                        icon: const Icon(Icons.tune),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      );
    });
    overlays.add('horizontalController');
  }

  void addVertexTapUpPanel(Size size) {
    if (options.vertexTapUpPanel != null) {
      overlays.addEntry('vertexTapUpPanel', (_, game) {
        return Stack(
          children: [
            Positioned(
              right: 0,
              top: options.horizontalControllerHeight,
              bottom: 10,
              child: ListenableBuilder(
                listenable: algorithm.$size,
                builder: (context, child) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: size.height,
                      maxWidth: options.vertexTapUpPanelWidth,
                    ),
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ColoredBox(
                            color: Colors.grey.withOpacity(0.1),
                            child: options.vertexTapUpPanel,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              right: 8,
              top: options.horizontalControllerHeight,
              child: IconButton(
                onPressed: hideVertexTapUpPanel,
                icon: const Icon(Icons.close),
              ),
            )
          ],
        );
      });
    }
  }

  void addVerticalOverlays(Size size) {
    overlays.addEntry('verticalController', (_, game) {
      return Stack(
        children: [
          Positioned(
            right: 0,
            top: options.horizontalControllerHeight,
            bottom: 10,
            child: ListenableBuilder(
              listenable: algorithm.$size,
              builder: (context, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: size.height,
                    maxWidth: options.verticalControllerWidth,
                  ),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ColoredBox(
                            color: Colors.grey.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                              child: Column(
                                children: algorithm.verticalOverlays(
                                      world: world,
                                      rootAlg: algorithm,
                                      graphComponent: this,
                                    ) ??
                                    [],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      );
    });
    // overlays.add('verticalController');
  }

  /// TODO 需要重构，以提高代码复用率
  ///
  /// needs to be refactored to improve code reuse
  void addLegendOverlays(Size size) {
    overlays.addEntry('legendOverlay', (_, game) {
      return Stack(
        children: [
          Positioned(
            left: 24,
            top: 32,
            bottom: 10,
            child: ListenableBuilder(
              listenable: algorithm.$size,
              builder: (context, child) {
                var leftOverlays = algorithm.leftOverlays(
                      world: world,
                      rootAlg: algorithm,
                      graphComponent: this,
                    ) ??
                    [];
                if (leftOverlays.isEmpty) {
                  return const SizedBox.shrink();
                }
                return ColoredBox(
                  color: Colors.grey.withOpacity(0.1),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: leftOverlays,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      );
    });
    if (!overlays.activeOverlays.contains('legendOverlay')) {
      overlays.add('legendOverlay');
    }
  }

  void removePauseListener() {
    options.pause.removeListener(pause);
  }

  void pause() {
    paused = options.pause.value;
  }
}
