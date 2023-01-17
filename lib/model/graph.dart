// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of graph component.
/// 图组件的数据模型
///
class Graph<ID> {
  List<Vertex<ID>> vertexes = [];
  Set<Edge> edges = {};

  Map<ID, Vertex<ID>> keyCache = {};

  Vertex<ID>? hoverVertex;

  List<Vertex<ID>> pickedVertex = [];

  dynamic data;
}
