// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of vertex component.
/// 节点组件的数据模型
///
class Vertex<I> {
  /// The primary key of vertex.
  /// 节点主键
  late I id;

  /// The first tag of vertex.
  /// 节点首个标签
  late String tag;

  /// All the tags of vertex.
  /// 节点所有标签
  List<String>? tags;

  /// Cache all the next edges of this vertex.
  /// 对当前节点的所有关系记录进行缓存。
  Set<Edge> nextEdges = {};

  /// Cache all the next vertexes of this vertex.
  /// 对当前节点的所有下游节点进行缓存。
  Set<Vertex<I>> nextVertexes = {};

  /// Cache all the previous vertexes of this vertex.
  /// 对当前节点的所有上游节点进行缓存。
  Set<Vertex<I>> prevVertexes = {};

  /// The degree of this vertex.
  /// 当前节点总的【度】数量
  int degree = 0;

  /// Is this vertex under focus now
  /// 当前节点是否有鼠标浮入
  bool hover = false;

  /// Whether this vertex being picked.
  bool picked = false;

  late List<Color> colors = [
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
  ];

  /// Default position of current vertex in graph.
  /// 节点在图中的默认位置。
  Vector2 position = Vector2(0, 0);

  /// The origin data of this vertex.
  late dynamic data;

  /// The radius of this vertex, that which assigment by StyleConfiguration.
  /// 节点的默认半径，用于被样式选项设置器进行修改以更新图形
  late double radius = 10;

  Vertex();
}
