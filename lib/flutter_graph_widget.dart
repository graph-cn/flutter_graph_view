// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.
import 'package:flame/extensions.dart';
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
  }

  late GraphComponent graphCpn;
  Map<String, Widget Function(BuildContext, GraphComponent)>
      overlayBuilderMap2 = {};

  @override
  Widget build(BuildContext context) {
    double? scale;
    Vector2 center = Vector2.zero();
    return Stack(
      children: [
        Positioned.fill(
          child: GameWidget(
            backgroundBuilder: widget.options?.backgroundBuilder,
            overlayBuilderMap: overlayBuilderMap2,
            game: graphCpn = GraphComponent(
              data: widget.data,
              convertor: widget.convertor,
              algorithm: widget.algorithm,
              options: widget.options,
              context: context,
            ),
          ),
        ),
        Positioned.fill(
            child: MouseRegion(
          onHover: (ev) => center = ev.localPosition.toVector2(),
          opaque: false,
        )),
        Positioned.fill(
            child: GestureDetector(
          onScaleUpdate: (ScaleUpdateDetails details) {
            // single finger pan
            if (details.pointerCount == 1) {
              var v = details.focalPointDelta.toVector2();
              graphCpn.onPanUpdate(v);
            } else if (details.pointerCount == 2) {
              graphCpn.onZoom(
                zoomCenter: center,
                zoomDelta: scale == null
                    ? (details.scale - 1)
                    : (details.scale - scale!),
              );
              scale = details.scale;
            }
          },
          onScaleEnd: (details) => scale = null,
        ))
      ],
    );
  }
}
