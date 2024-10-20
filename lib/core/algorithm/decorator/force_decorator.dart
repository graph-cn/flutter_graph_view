// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// ForceDecorator is a decorator that compute the total force of the vertex.
///
/// 计算顶点的总力的装饰器。
class ForceDecorator extends GraphAlgorithm {
  double sameTagsFactor;
  ForceDecorator({
    super.decorators,
    this.sameTagsFactor = 1,
  });

  @override
  void onLoad(Vertex v) {
    super.onLoad(v);
    v.cpn?.properties.putIfAbsent(
        'forceMap', () => <GraphAlgorithm, Map<Vertex, Vector2>>{});
    v.cpn!.properties['forceMap'][this] = <Vertex, Vector2>{};
    v.cpn?.properties.putIfAbsent('force', () => <Vertex, Vector2>{});
  }

  Map<GraphAlgorithm, Map<Vertex, Vector2>> getForceMap(Vertex v) =>
      v.cpn!.properties['forceMap']
          as Map<GraphAlgorithm, Map<Vertex, Vector2>>;

  setForceMap(Vertex v, Vertex d, Vector2 force) {
    if (v.position == Vector2.zero() || d.position == Vector2.zero()) return;
    var forceMap = v.cpn!.properties['forceMap']
        as Map<GraphAlgorithm, Map<Vertex, Vector2>>;
    forceMap[this]![d] = computeSameTagsFactor(force, v, d);
  }

  _setForce(Vertex v) {
    var forceMap = getForceMap(v);
    var force = Vector2.zero();
    for (var forces in forceMap.values) {
      for (var f in forces.values) {
        force += f;
      }
    }
    if (force == Vector2.zero()) {
      v.cpn!.properties['force'] = force;
      return;
    }
    var scaleX = (2 << 12) * (force.x > 0 ? 1 : -1) / force.x;
    var scaleY = (2 << 12) * (force.y > 0 ? 1 : -1) / force.y;
    var scaleMin = min(scaleX, scaleY);
    v.cpn!.properties['force'] = force * min(1, scaleMin);
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    _setForce(v);
  }

  Vector2 computeSameTagsFactor(Vector2 f, Vertex v, Vertex b) {
    if (v.tags != null && b.tags != null) {
      var sameTags = v.tags!.where((element) => b.tags!.contains(element));
      if (sameTags.isNotEmpty) {
        f = f * sameTagsFactor;
      }
    }
    return f;
  }
}
