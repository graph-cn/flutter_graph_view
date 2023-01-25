// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Provide an external Api interface to pass in data and policy specification.
///
/// 提供一个对外Api接口，用来传入数据与策略指定（风格策略、布局策略）
class FlutterGraphWidget extends StatefulWidget {
  final dynamic data;
  final GraphAlgorithm algorithm;
  final DataConvertor convertor;
  final Options? options;

  const FlutterGraphWidget({
    Key? key,
    required this.data,
    required this.convertor,
    required this.algorithm,
    this.options,
  }) : super(key: key);

  @override
  State<FlutterGraphWidget> createState() => _FlutterGraphWidgetState();
}

class _FlutterGraphWidgetState extends State<FlutterGraphWidget> {
  addVertex() {}

  addEdge() {}

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (widget.algorithm.$size.value != context.size) {
        graphCpn.clearPosition();
        widget.algorithm.$size.value = context.size;
      }

      addVertexOverlays();

      addEdgeOverlays();
    });
  }

  /// set overlays callback for vertex data panel on vertex hover.
  ///
  /// 设置浮层面板回调，在鼠标悬停时触发
  void addVertexOverlays() {
    graphCpn.overlays.addEntry('vertex', (_, game) {
      if (graphCpn.graph.hoverVertex == null) return const SizedBox();
      return widget.options?.vertexPanelBuilder!
              .call(graphCpn.graph.hoverVertex!) ??
          const SizedBox();
    });
  }

  void addEdgeOverlays() {
    graphCpn.overlays.addEntry('edge', (_, game) {
      if (graphCpn.graph.hoverEdge == null) return const SizedBox();
      return widget.options?.edgePanelBuilder!
              .call(graphCpn.graph.hoverEdge!) ??
          const SizedBox();
    });
  }

  late GraphComponent graphCpn;
  Map<String, Widget Function(BuildContext, GraphComponent)>
      overlayBuilderMap2 = {};

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      backgroundBuilder: (context) => Container(
        color: Colors.black54,
      ),
      overlayBuilderMap: overlayBuilderMap2,
      game: graphCpn = GraphComponent(
        data: widget.data,
        convertor: widget.convertor,
        algorithm: widget.algorithm,
        context: context,
      ),
    );
  }
}
