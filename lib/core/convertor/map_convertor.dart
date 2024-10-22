// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Default convertor for business data, key names in map as attrs' name of entity.
/// 默认的数据转换器，将 map 里 key 作为属性名转换成实体结构。
///
class MapConvertor extends DataConvertor<Map, Map> {
  /// Convert data from map to Vertex.
  /// 将数据从Map的格式官宦成Vertex的格式
  /// Map struc:
  /// {
  ///   "id": "",
  ///   "tag": "",
  ///   "tags": [],
  /// }
  @override
  Vertex convertVertex(v, g) {
    Vertex vertex = Vertex();
    vertex.id = v['id'];
    vertex.tag = v['tag'];
    vertex.tags = v['tags'];
    vertex.data = v['data'];
    return vertex;
  }

  /// Convert data from map to Edge.
  /// 将数据从Map的格式官宦成Edge的格式
  /// Map struc:
  /// {
  ///   "ranking": 1112,
  ///   "edgeName": "",
  ///   "srcId": "",
  ///   "dstId": "",
  /// }
  @override
  Edge convertEdge(e, g) {
    Edge result = Edge();
    result.ranking = e['ranking'];
    result.edgeName = e['edgeName'];

    result.start = g.keyCache[e['srcId']]!;
    result.end = g.keyCache[e['dstId']];

    return result;
  }

  /// Convert data from map to Graph.
  /// 将数据从Map的格式官宦成Graph的格式
  /// Map struc:
  /// {
  ///   "edges": [],
  ///   "vertexes": [],
  /// }
  @override
  Graph convertGraph(data, {Graph? graph}) {
    var result = graph ?? Graph();
    result.data = data;

    if (data is Map) {
      var edgeDataList = originEdges(data);
      var vertexDataList = originVertexes(data);
      for (var v in vertexDataList) {
        addVertex(v, result);
      }
      for (var e in edgeDataList) {
        addEdge(e, result);
      }
    }
    return result;
  }

  Iterable originVertexes(dynamic data) => data['vertexes'];

  Iterable originEdges(dynamic data) => data['edges'];
}
