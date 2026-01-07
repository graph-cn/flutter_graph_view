// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

export 'vertex_ext.dart';

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

  bool solid = true; // the color
  double radiusScale = 1.0;

  /// All the tags of vertex.
  /// 节点所有标签
  List<String>? tags;

  /// Cache all the next edges of this vertex.
  /// 对当前节点的后向关系记录进行缓存。
  Set<Edge> nextEdges = {};

  /// Cache all the prev edges of this vertex.
  /// 对当前节点的前向关系记录进行缓存。
  Set<Edge> prevEdges = {};

  /// get the neighbor vertexes of this vertex.
  /// 获取当前节点的所有关系。
  List<Edge> get neighborEdges => [...nextEdges, ...prevEdges];

  /// Cache all the next vertexes of this vertex.
  /// 对当前节点的所有下游节点进行缓存。
  Set<Vertex<I>> nextVertexes = {};

  /// Cache all the previous vertexes of this vertex.
  /// 对当前节点的所有上游节点进行缓存。
  Set<Vertex<I>> prevVertexes = {};

  /// get the neighbor vertexes of this vertex.
  /// 获取当前节点的邻居节点。
  List<Vertex<I>> get neighbors => [...nextVertexes, ...prevVertexes];

  /// get the neighbor vertexes of this vertex.
  ///
  /// 获取当前节点与另一个节点的共同邻居节点。
  Set<Vertex<I>> sameNeighbors(Vertex<I> vertex) {
    return neighbors.toSet().intersection(vertex.neighbors.toSet());
  }

  /// The degree of this vertex.
  /// 当前节点总的【度】数量
  int degree = 0;

  /// Whether this vertex being picked.
  bool picked = false;

  /// To get the center datum point , etc.
  ///
  /// 为了获得定位时的中心基准点，或者其他信息
  Vertex<I>? prevVertex;

  int deep = 1;

  List<Color> colors = [];

  /// Default position of current vertex in graph.
  /// 节点在图中的默认位置。
  Vector2 position = Vector2(0, 0);

  /// The origin data of this vertex.
  late dynamic data;

  double _radius = 5;

  set radius(double radius) => _radius = radius;

  /// The radius of this vertex, that which assigment by StyleConfiguration.
  /// 节点的默认半径，用于被样式选项设置器进行修改以更新图形
  double get radius => (math.log(degree * 10 + 1)) + _radius * radiusScale;

  /// The size of this vertex
  ///
  /// 节点的尺寸，提供给自定义形状的元素使用
  Size? size;

  bool visible = true;

  double get radiusZoom {
    return g == null ? radius : radius / zoom;
  }

  double get radiusActual => radius * (g?.zoom ?? 1) / zoom;

  double get zoom {
    if (g == null) return 1;
    return g!.zoom > 1
        ? math.log(g!.scale.value * math.e)
        : (1 + g!.scale.value) / 2;
  }

  Vertex();

  /// Is this vertex under focus now
  ///
  /// 当前节点是否有鼠标浮入
  bool get isHovered {
    if (this.g == null) return false;
    var g = this.g as Graph;
    // 排他
    if (g.hoverVertex != null && g.hoverVertex != this) return false;
    return g.options!.vertexShape.hoverTest(this);
  }

  Graph? g;

  bool get isCenter => neighbors.fold(
        true,
        (previousValue, element) =>
            previousValue &&
            (degree > element.degree ||
                (degree == element.degree && element.prevVertex == this)),
      );

  final Map<String, dynamic> properties = {};

  @override
  String toString() {
    return '$position, $radius';
  }

  /// Uniqueness based on primary key
  ///
  /// 只取主键作为唯一性的依据
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Vertex && other.id == id);

  double angle(Vertex v, Vertex b) {
    var vc = v.position - position;
    var bc = b.position - position;
    return vc.angleTo(bc);
  }

  Map<String, dynamic> serialize() =>
  {
    "id": id as String,
    "position": position,
    "radius": radius,
    "tag": tag,
    "tags": tags,
    "neighbors": neighbors.map((n) => n.id as String).toList(),
    "degree": degree,
    // TODO: how do we safely pass in properties
    // "properties": properties
  };
}
