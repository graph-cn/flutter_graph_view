// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/cupertino.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data model of graph component.
/// 图组件的数据模型
///
class Graph<ID> {
  Options? options;
  GraphAlgorithm? algorithm;
  DataConvertor? convertor;
  ValueNotifier<Size> get size => options!.size;

  /// All the vertexes' data in graph in List form.
  /// 图中所有的节点数据
  final List<Vertex<ID>> vertexes = [];

  /// All the vertexes' data in Map form with the vertex id as the key. This is very
  /// useful if you want to get O(1) search to get a vertex by id
  Map<ID, Vertex<ID>> get vertexByIdMap =>
      {for (var vertex in vertexes) vertex.id: vertex};

  /// All the edges' data in graph.
  /// 图中所有的关系数据
  Set<Edge> edges = {};

  /// Cache the key and vertex in order to get vertex by id.
  /// 对节点的 id 进行缓存，为了方便通过 id 获取到接点
  Map<ID, Vertex<ID>> keyCache = {};

  /// 记算鼠标上次触碰节点的开始时间
  Map<Vertex?, DateTime> vHoverTime = {};

  final Map<String, dynamic> extraOnLoad = {};

  /// The vertex which is focused by mouse.
  /// 鼠标浮入所命中的节点，用于做高亮显示。
  Vertex<ID>? _hoverVertex;

  Vertex<ID>? get hoverVertex => _hoverVertex;

  set hoverVertex(Vertex<ID>? v) {
    if (v == _hoverVertex) return;
    vHoverTime.putIfAbsent(v, DateTime.now);
    if (v == null) vHoverTime.remove(_hoverVertex);
    _hoverVertex = v;
  }

  bool showPanel(Vertex<ID> v) {
    if (_hoverVertex != v) return false;
    var vTime = vHoverTime[v];
    if (vTime == null) return false;
    var delay = options?.panelDelay ?? const Duration(milliseconds: 300);
    if (vTime.add(delay).compareTo(DateTime.now()) < 0) {
      return true;
    }
    return false;
  }

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

  @Deprecated('Use edgesBetweenHash instead')
  Map<Vertex, Map<Vertex, List<Edge>>> edgesBetween = {};

  static final String _split = '{__${DateTime.now().microsecondsSinceEpoch}__}';

  /// When displaying the edge, the direction of the edge is not considered,
  /// only the two nodes of the edge are considered,
  /// so a hash table is used here to store the two nodes of the edge for calculating the index of the edge,
  /// in a multi-graph with the same two nodes, the position of the edge can be determined according to the subscript.
  ///
  /// 在显示边时，不考虑边的方向，只考虑边的两个节点，
  /// 所以这里使用了一个哈希表来存储边的两个节点，以便计算边的索引，
  /// 在相同两个节点的多边图中，可以根据下标决定边的位置。
  Map<String, List<Edge>> edgesBetweenHash = {};

  List<Vertex> get centerVertexes {
    return vertexes.where((element) => element.isCenter).toList();
  }

  List<Edge> edgesFromTwoVertex(Vertex start, Vertex? end) {
    if (end == null) return [];
    return edgesBetweenHash[edgesBetweenKey(start, end)] ?? [];
  }

  static String edgesBetweenKey(Vertex start, Vertex end) {
    var key = start.id.hashCode > end.id.hashCode
        ? '${end.id}$_split${start.id}'
        : '${start.id}$_split${end.id}';
    return key;
  }

  void clear() {
    vertexes.clear();
    edges.clear();
    keyCache.clear();
    hoverVertex = null;
    hoverEdge = null;
    pickedVertex.clear();
    allTags.clear();
    allEdgeNames.clear();
    edgesBetweenHash.clear();
  }

  double get zoom => options?.scale.value ?? 1;
  ValueNotifier get scale => options!.scale;
  void Function(dynamic data)? get refreshData => options?.refreshData;
  void Function(dynamic graphData, {bool manual})? get mergeGraph =>
      options?.mergeGraph;

  /// serialize the graph
  Map<String, dynamic> serialize() =>
    {
      "vertexes": { for (var v in vertexes) v.id as String: v.serialize() },
    };
}
