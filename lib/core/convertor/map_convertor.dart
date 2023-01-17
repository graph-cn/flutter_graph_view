// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Default convertor for business data, key names in map as attrs' name of entity.
/// 默认的数据转换器，将 map 里 key 作为属性名转换成实体结构。
///
class MapConvertor extends DataConvertor<Map, Map> {
  @override
  Vertex convertVertex(v, g) {
    Vertex vertex = Vertex();
    vertex.id = v['id'];
    vertex.tag = v['tag'];
    vertex.tags = v['tags'];
    vertexAsGraphComponse(v, g, vertex);
    return vertex;
  }

  @override
  Edge convertEdge(e, g) {
    Edge result = Edge();
    result.ranking = e['ranking'];
    result.edgeName = e['edgeName'];

    result.start = g.keyCache[e['srcId']]!;
    result.end = g.keyCache[e['dstId']];

    edgeAsGraphComponse(e, g, result);

    return result;
  }

  @override
  Graph convertGraph(data) {
    var result = Graph();
    result.data = data;

    if (data is Map) {
      var edgeDataList = data['edges'] as Iterable;
      var vertexDataList = data['vertexes'] as Iterable;
      for (var v in vertexDataList) {
        Vertex vertex = convertVertex(v, result);
        result.vertexes.add(vertex);
      }
      for (var e in edgeDataList) {
        Edge edge = convertEdge(e, result);
        result.edges.add(edge);
      }
    }
    return result;
  }
}
