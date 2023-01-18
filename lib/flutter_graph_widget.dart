// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Provide an external Api interface to pass in data and policy specification.
/// 提供一个对外Api接口，用来传入数据与策略指定（风格策略、布局策略）
///

class FlutterGraphWidget extends StatefulWidget {
  final dynamic data;
  final GraphAlgorithm algorithm;
  final DataConvertor convertor;

  const FlutterGraphWidget({
    Key? key,
    required this.data,
    required this.convertor,
    required this.algorithm,
  }) : super(key: key);

  @override
  State<FlutterGraphWidget> createState() => _FlutterGraphWidgetState();
}

class _FlutterGraphWidgetState extends State<FlutterGraphWidget> {
  addVertex() {}

  addEdge() {}

  @override
  Widget build(BuildContext context) {
    widget.algorithm.size =
        widget.algorithm.size ?? MediaQuery.of(context).size;
    return GameWidget(
      game: GraphComponent(
        data: widget.data,
        convertor: widget.convertor,
        algorithm: widget.algorithm,
        context: context,
      ),
    );
  }
}
