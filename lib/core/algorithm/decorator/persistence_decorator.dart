// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Load and save location of vertex positions
///
/// 加载并保存顶点位置
class PersistenceDecorator extends ForceDecorator {
  final void Function(Vertex) saveVertex;
  final Map<dynamic, Vertex?> Function() loadVertex;
  late Map<dynamic, Vertex?> _positionMap;

  PersistenceDecorator(this.saveVertex, this.loadVertex) {
    _positionMap = loadVertex();
    _positionMap.forEach((key, vertex) {});
  }

  @override
  void onLoad(Vertex v) {
    super.onLoad(v);

    if (_positionMap.containsKey(v.id) && _positionMap[v.id] != null) {
      v.position = _positionMap[v.id]!.position;
      getForceMap(v).forEach((key, forces) {
        forces.forEach((key, value) {
          forces[key] = Vector2.zero();
        });
      });
    }
  }

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    Vertex? cachedVertex = _positionMap[v];
    if (cachedVertex == null ||
        cachedVertex.position.x != v.position.x ||
        cachedVertex.position.y != v.position.y) {
      saveVertex(v);
    }
    _positionMap[v.id] = v;
  }
}
