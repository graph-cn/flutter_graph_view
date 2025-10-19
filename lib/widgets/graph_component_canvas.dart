// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class GraphComponentCanvas extends StatefulWidget {
  final dynamic data;
  final GraphAlgorithm algorithm;
  final DataConvertor convertor;
  final BuildContext context;
  final Options options;
  final Graph graph;

  const GraphComponentCanvas({
    super.key,
    required this.data,
    required this.algorithm,
    required this.context,
    required this.convertor,
    required this.options,
    required this.graph,
  });

  @override
  State<GraphComponentCanvas> createState() => _GraphComponentCanvasState();
}

class _GraphComponentCanvasState extends State<GraphComponentCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Graph get graph => widget.graph;

  GraphAlgorithm get algorithm => widget.algorithm;
  dynamic get data => widget.data;
  DataConvertor get convertor => widget.convertor;
  Options get options => widget.options;

  ValueNotifier<double> get scale => options.scale;
  ValueNotifier<Offset> get offset => options.offset;
  ValueNotifier<int> timestamp = ValueNotifier(0);

  update() {
    timestamp.value = DateTime.now().millisecondsSinceEpoch;
  }

  playOrPause() {
    if (options.pause.value) _controller.stop();
    if (!options.pause.value) _controller.repeat();
  }

  run() {
    if (graph.vertexes.isEmpty) return;
    options.run();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((t) {
      var size = (context.findRenderObject() as RenderBox).size;
      algorithm.$size.value = Size(size.width, size.height);
      options.size.value = Size(size.width, size.height);
      options.refreshData(data);
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // 长期运行
    )..addListener(run);
    _controller.repeat();

    options.pause.addListener(playOrPause);
    offset.addListener(update);
    scale.addListener(update);
  }

  @override
  void dispose() {
    offset.removeListener(update);
    scale.removeListener(update);
    options.pause.removeListener(playOrPause);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: options.backgroundBuilder.call(context)),
        Positioned.fill(
          child: ListenableBuilder(
            listenable: timestamp,
            builder: (context, child) {
              return Transform.translate(
                offset: offset.value,
                child: Transform.scale(
                  scale: scale.value,
                  child: CustomPaint(
                    painter: GraphPainter(graph),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned.fill(
            child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerHover: options.onPointerHover,
          onPointerUp: options.onPointerUp,
          onPointerSignal: options.onPointerSignal,
        )),
        Positioned.fill(
          child: GestureDetector(
            // 为了不让在拖动画面的过程中，触碰到点，变成拖动节点
            onScaleStart: options.onScaleStart,
            onScaleUpdate: options.onScaleUpdate,
            onScaleEnd: (d) {
              options.hoverable = true;
            },
            behavior: HitTestBehavior.translucent,
          ),
        ),
        verticalController,
        legend(),
        ...vertexTapUpPanel,
        horizontalController,
        dataPanel(),
      ],
    );
  }

  Widget dataPanel() {
    return Positioned.fill(
        child: Stack(
      children: [
        if (options.edgePanelBuilder != null)
          ...graph.edges.where((e) => graph.hoverEdge == e).map((e) {
            return options.edgePanelBuilder!.call(e);
          }),
        if (options.vertexPanelBuilder != null)
          ...graph.vertexes.where(graph.showPanel).map((v) {
            return options.vertexPanelBuilder!.call(v);
          })
      ],
    ));
  }

  Widget get horizontalController {
    return Positioned(
      top: 0,
      right: 0,
      child: ListenableBuilder(
          listenable: options.horizontalPanelVisible,
          builder: (context, child) {
            return Offstage(
              offstage: !options.horizontalPanelVisible.value,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: options.size.value.width,
                  maxHeight: options.horizontalControllerHeight,
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...(algorithm.horizontalOverlays(
                            rootAlg: algorithm,
                            graph: graph,
                          ) ??
                          []),
                      if (algorithm
                              .verticalOverlays(
                                  rootAlg: algorithm, graph: graph)
                              ?.isNotEmpty ==
                          true)
                        IconButton(
                          onPressed: () {
                            if (options.verticalControllerVisible.value) {
                              options.hideVerticalPanel();
                            } else {
                              options.showVerticalPanel();
                            }
                          },
                          icon: const Icon(Icons.tune),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  List<Widget> get vertexTapUpPanel {
    return [
      Positioned(
        right: 0,
        top: options.horizontalControllerHeight,
        bottom: 10,
        child: Offstage(
          offstage: !options.vertexTapUpPanelVisible.value,
          child: ListenableBuilder(
            listenable: algorithm.$size,
            builder: (context, child) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: options.size.value.height,
                  maxWidth: options.vertexTapUpPanelWidth,
                ),
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ColoredBox(
                        color: Colors.grey.withValues(alpha: 0.1),
                        child: options.vertexTapUpPanel,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      Positioned(
        right: 8,
        top: options.horizontalControllerHeight,
        child: Offstage(
          offstage: !options.vertexTapUpPanelVisible.value,
          child: IconButton(
            onPressed: options.hideVertexTapUpPanel,
            icon: const Icon(Icons.close),
          ),
        ),
      ),
    ];
  }

  Widget get verticalController {
    return Positioned(
      right: 0,
      top: options.horizontalControllerHeight,
      bottom: 10,
      child: ListenableBuilder(
        listenable: options.verticalControllerVisible,
        builder: (context, child) {
          return Offstage(
            offstage: !options.verticalControllerVisible.value,
            child: ListenableBuilder(
              listenable: algorithm.$size,
              builder: (context, child) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: options.size.value.height,
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
                            color: Colors.grey.withValues(alpha: 0.1),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
                              child: Column(
                                children: algorithm.verticalOverlays(
                                        rootAlg: algorithm, graph: graph) ??
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
          );
        },
      ),
    );
  }

  Widget legend() {
    return Positioned(
      left: 24,
      top: 32,
      bottom: 10,
      child: ListenableBuilder(
        listenable: algorithm.$size,
        builder: (context, child) {
          var leftOverlays = algorithm.leftOverlays(
                rootAlg: algorithm,
                graph: graph,
              ) ??
              [];
          if (leftOverlays.isEmpty) {
            return const SizedBox.shrink();
          }
          return ColoredBox(
            color: Colors.grey.withValues(alpha: 0.1),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              hitTestBehavior: HitTestBehavior.translucent,
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
    );
  }
}
