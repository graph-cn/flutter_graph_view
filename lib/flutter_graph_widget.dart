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
class FlutterGraphWidget extends StatelessWidget {
  dynamic data;
  late GraphAlgorithm algorithm;
  late DataConvertor convertor;

  Set<dynamic> pickedIds = {};

  FlutterGraphWidget({
    Key? key,
    required this.data,
    DataConvertor? convertor,
    GraphAlgorithm? algorithm,
  }) : super(key: key) {
    this.convertor = convertor ?? MapConvertor();
    this.algorithm = algorithm ?? ForceDirected();
  }

  addVertex() {}

  addEdge() {}

  @override
  Widget build(BuildContext context) {
    algorithm.size = algorithm.size ?? MediaQuery.of(context).size;
    return GameWidget(
      game: GraphComponent(
        data: data,
        convertor: convertor,
        algorithm: algorithm,
        context: context,
      ),
    );
  }
}
