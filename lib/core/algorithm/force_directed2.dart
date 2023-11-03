import 'dart:collection';
import 'dart:math';

import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Force oriented map layout algorithm. v2.0
///
/// 力导向图布局算法 v2.0
class ForceDirected2 extends GraphAlgorithm {
  ForceDirected2([super.decorator]);

  Map<dynamic, double> mDxMap = HashMap();
  Map<dynamic, double> mDyMap = HashMap();
  late double k;

  @override
  void onLoad(Vertex v) {
    if (v.position == Vector2(0, 0)) {
      var ct = Util.toOffsetByVector2(v.prevVertex?.position) ?? center / 2;
      var distanceFromCenter = 1 / v.deep * offset;
      var noAllowCircleRadius = .3 * distanceFromCenter;
      v.position = randomInCircle(ct, distanceFromCenter, noAllowCircleRadius);

      for (var n in v.nextVertexes) {
        if (n.prevVertex == null) {
          n.prevVertex = v;
          n.deep = v.deep + 1;
        }
      }
    }

    k = sqrt(v.cpn!.size.x * v.cpn!.size.y / v.cpn!.graph.vertexes.length);
  }

  @override
  void onDrag(Vertex hoverVertex, DragUpdateInfo info, Viewfinder viewfinder) {
    var deltaPosition = info.delta.global;
    var zoom = viewfinder.zoom;
    hoverVertex.position += deltaPosition / zoom;
  }

  void collide(Vertex v, Graph g) {
    calculateRepulsive(v, g);
    calculateTraction(v, g);
    updateCoordinates(v, g);
  }

  void calculateRepulsive(Vertex v, Graph graph) {
    int ejectFactor = 6;
    double distX, distY, dist;
    for (int v = 0; v < graph.vertexes.length; v++) {
      mDxMap[graph.vertexes[v].id] = 0.0;
      mDyMap[graph.vertexes[v].id] = 0.0;
      for (int u = 0; u < graph.vertexes.length; u++) {
        if (u != v) {
          distX = graph.vertexes[v].position.x - graph.vertexes[u].position.x;
          distY = graph.vertexes[v].position.y - graph.vertexes[u].position.y;
          dist = sqrt(distX * distX + distY * distY);
          if (dist < 30) {
            ejectFactor = 5;
          }
          if (dist > 0 && dist < 250) {
            dynamic id = graph.vertexes[v].id;
            mDxMap[id] =
                (mDxMap[id] ?? 0) + distX / dist * k * k / dist * ejectFactor;
            mDyMap[id] =
                (mDyMap[id] ?? 0) + distY / dist * k * k / dist * ejectFactor;
          }
        }
      }
    }
  }

  void calculateTraction(Vertex v, Graph graph) {
    int condenseFactor = 3;
    for (Edge e in graph.edges) {
      Vertex start = e.start;
      Vertex? end = e.end;
      dynamic startId = e.start.id;
      dynamic endId = e.end?.id;
      if (end == null) {
        return;
      }
      double distX, distY, dist;
      distX = start.position.x - end.position.x;
      distY = start.position.x - end.position.y;
      dist = sqrt(distX * distX + distY * distY);
      mDxMap[startId] =
          (mDxMap[startId] ?? 0) - distX * dist / k * condenseFactor;
      mDyMap[startId] =
          (mDyMap[startId] ?? 0) - distY * dist / k * condenseFactor;
      mDxMap[endId] = (mDxMap[endId] ?? 0) + distX * dist / k * condenseFactor;
      mDyMap[endId] = (mDyMap[endId] ?? 0) + distY * dist / k + condenseFactor;
    }
  }

  void updateCoordinates(Vertex v, Graph graph) {
    var mNodeList = graph.vertexes;
    int maxt = 4, maxty = 3; //Additional coefficients.
    for (int v = 0; v < mNodeList.length; v++) {
      Vertex node = mNodeList[v];
      int dx = mDxMap[node.id]?.floor() ?? 0;
      int dy = mDyMap[node.id]?.floor() ?? 0;

      if (dx < -maxt) dx = -maxt;
      if (dx > maxt) dx = maxt;
      if (dy < -maxty) dy = -maxty;
      if (dy > maxty) dy = maxty;

      node.position.x += dx;
      node.position.y += dy;
    }
  }

  @override
  void repositionWhenCollision(Vertex me, Vertex another) {}

  Random random = Random();

  /// Generates random positions in a specific circle.
  ///
  /// 在一个指定的圆周区域内生成随机位置
  Vector2 randomInCircle(Offset center, double distance, double rOffset) {
    var dr = random.nextDouble() * distance + rOffset;
    var angle = random.nextDouble() * pi;
    var s = sin(angle);
    var c = cos(angle);

    double x, y;

    var dx = dr * c * (random.nextBool() ? 1 : -1);
    var dy = dr * s * (random.nextBool() ? 1 : -1);

    x = center.dx + dx;
    y = center.dy + dy;

    return Vector2(x, y);
  }

  @override
  void compute(Vertex v, Graph graph) {
    collide(v, v.cpn!.graph);
  }
}
