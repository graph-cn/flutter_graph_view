// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' hide TextStyle;
import 'package:flutter/painting.dart';
import 'dart:math' as math;

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The graph style configuration.
///
/// 图的样式配置类。
class GraphStyle {
  /// [tagColor] is prior to [tagColorByIndex]. use [Vertex.tags] to get color in [vertexColors]
  ///
  /// [tagColor]的优先级比[tagColorByIndex]高。
  /// 在[vertexColors]方法中使用[Vertex.tags]属性获取颜色
  Map<String, Color>? tagColor;

  /// [tagColor] is prior to [tagColorByIndex]. use [Vertex.tags] to get color in [vertexColors]
  ///
  /// [tagColor]的优先级比[tagColorByIndex]高。
  /// 在[vertexColors]方法中使用[Vertex.tags]属性获取颜色
  late List<Color> tagColorByIndex = [];

  /// set elements color in [graph]
  ///
  /// 对[graph]中的元素设置颜色
  void graphColor(Graph graph) {
    for (var vertex in graph.vertexes) {
      vertex.colors = vertexColors(vertex);
    }
    // TODO set edge color
  }

  /// get color list by [vertex]'s `tags`.
  ///
  /// 通过[vertex]中的`tags`属性获取颜色列表
  List<Color> vertexColors(Vertex vertex) {
    var tags = vertex.tags;
    var allTags = vertex.g!.allTags;

    if (tags == null) {
      return defaultColor();
    }
    List<Color> colors = [];

    for (var tag in tags) {
      Color? color = colorByTag(tag, allTags);
      if (color != null) {
        colors.add(color);
      }
    }

    if (colors.isEmpty) {
      return defaultColor();
    }
    return colors;
  }

  Color? colorByTag(String tag, List<String> allTags) {
    Color? color;
    if (tagColor != null) {
      color = tagColor![tag];
    }
    if (color == null) {
      var idx = allTags.indexOf(tag);
      if (idx < tagColorByIndex.length) color = tagColorByIndex[idx];
    }
    return color;
  }

  /// when there is not color matched in [tagColor] on [tagColorByIndex], return random color.
  ///
  /// 当在 [tagColor] 与 [tagColorByIndex] 中匹配不到颜色时，返回随机颜色
  var defaultColor = () {
    var r = math.Random();
    return [
      Color.fromRGBO(
        r.nextInt(160) + 80,
        r.nextInt(160) + 80,
        r.nextInt(160) + 80,
        1,
      ),
      Color.fromRGBO(
        r.nextInt(160) + 80,
        r.nextInt(160) + 80,
        r.nextInt(160) + 80,
        1,
      ),
    ];
  };

  /// @en: the hover opacity of vertex and edge when hover.
  ///
  /// @zh: 顶点悬停时，非激活点边的透明度
  double hoverOpacity = 0.3;

  /// @en: the text style of vertex.
  /// now is only supports:
  /// - `fontSize`
  /// - `fontWeight`
  /// - `fontColor`
  ///
  /// @zh: 顶点文字样式
  /// 目前仅支持：
  /// - `fontSize`
  /// - `fontWeight`
  /// - `fontColor`
  VertexTextStyleGetter? vertexTextStyleGetter;

  /// @en: the text style of edge.
  /// now is only supports:
  /// - `fontSize`
  /// - `fontWeight`
  /// - `fontColor`
  ///
  /// @zh: 顶点文字样式
  /// 目前仅支持：
  /// - `fontSize`
  /// - `fontWeight`
  /// - `fontColor`
  EdgeTextStyleGetter? edgeTextStyleGetter;
}
