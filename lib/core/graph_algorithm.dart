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
  GraphAlgorithm? decorate;

  ///
  ///
  GraphAlgorithm(this.decorate);

  ///
  /// Stage size.
  /// 图形展示的区域边界
  ///
  Size? size;

  /// Center of stage.
  /// 图形展示的中心点
  Offset get center => Offset(size?.width ?? 0 / 2, size?.height ?? 0 / 2);

  /// Nodes zoom offset from center.
  /// 节点区域相对中心点的偏移量。
  double get offset => min(center.dx, center.dy) * 0.4;

  ///
  /// Position setter.
  /// 对节点进行定位设值
  ///
  void compute(Vertex v, Graph graph);
}
