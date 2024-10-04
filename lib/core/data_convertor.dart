// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data format converter interface:
///     used to convert business data into data required by component format.
///
/// 数据格式转换器接口：
///     用于将业务数据转换成组件格式要求的数据
///
abstract class DataConvertor<V, E> {
  /// Convert data struc from business to Vertex.
  ///
  /// 将业务数据转换成节点数据
  Vertex convertVertex(V v, Graph graph);

  /// Convert data struc from business to Edge.
  ///
  /// 将业务数据转换成 【边 | 关系】 数据
  Edge convertEdge(E e, Graph graph);

  /// Convert data struc from business to Graph.
  ///
  /// 将业务数据转换成 图数据，同时提取点跟线便于使用的数据格式。
  Graph convertGraph(dynamic data, {Graph? graph});

  /// Create vertex and graph relationship in memory.
  ///
  /// 将节点纳入图的全局管理
  @mustCallSuper
  void vertexAsGraphComponse(V v, Graph<dynamic> g, Vertex<dynamic> vertex) {
    vertex.data = v;
    g.keyCache[vertex.id] = vertex;

    vertex.tags?.forEach((tag) {
      var absent = !g.allTags.contains(tag);
      if (absent) g.allTags.add(tag);
    });
  }

  /// Create edge and graph relationship in memory.
  ///
  /// 将边纳入图的全局管理
  @mustCallSuper
  void edgeAsGraphComponse(E e, Graph<dynamic> g, Edge result) {
    if (result.end != null) {
      result.start.nextVertexes.add(result.end!);
      result.start.nextEdges.add(result);
      result.end!.degree++;
      result.end!.prevVertexes.add(result.start);
      result.end!.prevEdges.add(result);
    }
    result.start.degree++;
    result.data = e;

    var absent = !g.allEdgeNames.contains(result.edgeName);
    if (absent) g.allEdgeNames.add(result.edgeName);

    fillEdgesBetween(g, result);
  }

  /// cache for edge list between two vertex.
  ///
  /// 对两个节点间的边集合进行缓存，以计算边的位置偏移量
  void fillEdgesBetween(Graph g, Edge result) {
    var end = result.end;
    if (end == null) return;
    var start = result.start;

    var key = Graph.edgesBetweenKey(start, end);
    var list = g.edgesBetweenHash.putIfAbsent(key, () => []);
    if (!list.contains(result)) list.add(result);
  }

  /// Add data and component when absent.
  ///
  /// 提供边的去重方法，当不存在时添加
  Edge addEdge(E e, Graph graph) {
    var sameEdge = graph.edges.where((edgeIn) => edgeIn == e).toList();
    Edge edge;
    if (sameEdge.isEmpty) {
      edge = convertEdge(e, graph);
      edgeAsGraphComponse(e, graph, edge);
      graph.edges.add(edge);
    } else {
      edge = sameEdge.first;
    }
    return edge;
  }

  /// Add data and component when absent.
  ///
  /// 提供边的去重方法，当不存在时添加
  Vertex addVertex(V v, Graph graph) {
    Vertex vertex = convertVertex(v, graph);
    var sameVertex =
        graph.vertexes.where((edgeIn) => edgeIn == vertex).toList();
    if (sameVertex.isEmpty) {
      vertexAsGraphComponse(v, graph, vertex);
      graph.vertexes.add(vertex);
    } else {
      vertex = sameVertex.first;
    }
    return vertex;
  }
}
