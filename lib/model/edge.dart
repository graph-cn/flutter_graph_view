// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of edge component.
/// 关系【边】组件的数据模型
///
class Edge {
  late int ranking;
  late String edgeName;
  late dynamic data;
  late Vertex start;
  Vertex? end;
  late List<Color> colors;
}
