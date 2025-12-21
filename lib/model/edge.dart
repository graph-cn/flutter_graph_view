// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:typed_data';
import 'package:flutter/rendering.dart' as r;
import 'dart:ui';

import 'package:flutter_graph_view/core/util.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Data model of edge component.
///
/// 关系【边】组件的数据模型
class Edge {
  /// The key for edge.
  ///
  /// 关系键
  late int ranking;

  /// The name of edge.
  ///
  /// 关系名
  late String edgeName;

  /// Edge data, will display in panel by hover callback.
  ///
  /// 关系的原始数据，将通过回调展示在自定义面板上
  late dynamic data;

  /// Cache the source vertex.
  ///
  /// 对当前关系的起始节点进行缓存
  late Vertex start;

  bool solid = false;

  /// Cache the destination vertex.
  ///
  /// 对当前关系的终止节点进行缓存
  Vertex? end;

  /// Cache the colors for this edge.
  ///
  /// 颜色放置器，用于缓存当前关系所需使用到的颜色
  late List<Color> colors;

  /// Is this edge under focus now
  ///
  /// 当前边是否有鼠标浮入
  bool isHovered = false;

  bool visible = true;

  Graph? g;
  Vector2 get size => g!.options!.edgeShape.size(this);
  double get zoom => start.zoom;
  Path? path;

  bool get isLoop => start == end;

  Vector2 get position {
    if (end == start) {
      return start.position + Vector2(start.radiusZoom, 0);
    }
    var e = end!.position;
    var s = start.position;
    var distance = Util.distance(s, e);
    var c = (s + e) / 2;
    var dcy = s.y - c.y;
    var dcx = c.x - s.x;

    var edgesBetweenTwoVertex = g?.edgesFromTwoVertex(start, end) ?? [];
    var nl = computeIndex * distance / edgesBetweenTwoVertex.length;
    var nx = dcy / (distance / 2) * nl;
    var ny = dcx / (distance / 2) * nl;
    var n = c + Vector2(nx, ny);
    return n;
  }

  double get computeIndex {
    var edgeList = g?.edgesFromTwoVertex(start, end) ?? [];
    var idx = edgeList.indexOf(this);
    var result = 0.0;
    if (edgeList.length.isOdd) {
      if (idx.isEven) {
        result = idx / 2;
      } else {
        result = -(idx + 1) / 2;
      }
    } else {
      if (idx.isEven) {
        result = idx / 2 + 0.5;
      } else {
        result = -(idx - 1) / 2 - 0.5;
      }
    }

    return start.id.hashCode > end!.id.hashCode ? -result : result = result;
  }

  int get edgeIdx {
    var edgeList = g?.edgesFromTwoVertex(start, end) ?? [];
    var idx = edgeList.indexOf(this);
    return idx;
  }

  double get edgeIdxRatio {
    var edgeList = g?.edgesFromTwoVertex(start, end) ?? [];
    var ratio = edgeList.indexOf(this) / edgeList.length;
    return ratio;
  }

  /// Uniqueness based on primary key of triple.
  ///
  /// 只取三元组主键作为唯一性的依据
  @override
  int get hashCode => Object.hash(start, ranking, end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Edge &&
          other.ranking == ranking &&
          other.start == start &&
          other.end == end &&
          other.edgeName == edgeName);

  double get length {
    return g?.options?.edgeShape.len(this) ?? 0;
  }

  Float64List edgeCenter() {
    late r.Matrix4 matrix4;
    if (g?.options?.edgeShape == null) {
      matrix4 = r.Matrix4.zero();
    } else {
      matrix4 = g!.options!.edgeShape.edgeCenter(this);
    }
    return Float64List.fromList(matrix4.storage.toList());
  }
}
