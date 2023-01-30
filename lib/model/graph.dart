// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of graph component.
/// 图组件的数据模型
///
class Graph<ID> {
  /// All the vertexes' data in graph.
  /// 图中所有的节点数据
  List<Vertex<ID>> vertexes = [];

  /// All the edges' data in graph.
  /// 图中所有的关系数据
  Set<Edge> edges = {};

  /// Cache the key and vertex in order to get vertex by id.
  /// 对节点的 id 进行缓存，为了方便通过 id 获取到接点
  Map<ID, Vertex<ID>> keyCache = {};

  /// The vertex which is focused by mouse.
  /// 鼠标浮入所命中的节点，用于做高亮显示。
  Vertex<ID>? hoverVertex;

  /// The edge which is focused by mouse.
  ///
  /// 鼠标浮入所命中的边时存储当前边，用于做快速访问做处理。
  Edge? hoverEdge;

  /// The vertexes selected by the user.
  /// 被用户所选中的节点
  List<Vertex<ID>> pickedVertex = [];

  /// The origin business data of graph.
  /// 图的原始业务数据。
  dynamic data;

  /// cache the all tags of vertexes.
  ///
  /// 缓存所有的节点标签
  List<String> allTags = [];

  /// cache the all edge name
  ///
  /// 缓存所有的边类型
  List<String> allEdgeNames = [];
}
