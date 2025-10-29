// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Provide an external Api interface to pass in data and policy specification.
///
/// 提供一个对外Api接口，用来传入数据与策略指定（风格策略、布局策略）
class FlutterGraphWidget extends StatelessWidget {
  final dynamic data;
  final GraphAlgorithm algorithm;
  final DataConvertor convertor;
  final Options options;
  final Graph graph = Graph();

  FlutterGraphWidget({
    Key? key,
    required this.data,
    required this.convertor,
    required this.algorithm,
    Options? options,
  })  : options = options ?? Options(),
        super(key: key) {
    graph.options = options;
    this.options.graph = graph;
    graph.convertor = convertor;
    graph.algorithm = algorithm;
    algorithm.setGlobalData(rootAlg: algorithm, graph: this.graph);
  }

  @override
  Widget build(BuildContext context) {
    return options.graphComponentBuilder(
      key: ValueKey(graph),
      data: data,
      convertor: convertor,
      algorithm: algorithm,
      options: options,
      context: context,
      graph: graph,
    );
  }
}
