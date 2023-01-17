// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

///
/// Data format converter interface:
///     used to convert business data into data required by component format.
/// 数据格式转换器接口：
///     用于将业务数据转换成组件格式要求的数据
///
abstract class DataConvertor<V, E> {
  Vertex convertVertex(V v, Graph graph);

  Edge convertEdge(E e, Graph graph);

  Graph convertGraph(dynamic data);

  void vertexAsGraphComponse(V v, Graph<dynamic> g, Vertex<dynamic> vertex) {
    vertex.data = v;
    g.keyCache[vertex.id] = vertex;
  }

  void edgeAsGraphComponse(E e, Graph<dynamic> g, Edge result) {
    if (result.end != null) {
      result.start.nextVertexes.add(result.end!);
      result.start.nextEdges.add(result);
      result.end!.degree++;
      result.end!.prevVertexes.add(result.start);
    }
    result.start.degree++;
    result.data = e;
  }
}
