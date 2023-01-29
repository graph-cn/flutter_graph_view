// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

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

  /// Cache the destination vertex.
  ///
  /// 对当前关系的终止节点进行缓存
  Vertex? end;

  /// Cache the colors for this edge.
  ///
  /// 颜色放置器，用于缓存当前关系所需使用到的颜色
  late List<Color> colors;

  /// cache the component for edge model.
  ///
  /// 边模型缓存其对应的组件元素
  EdgeComponent? cpn;

  /// Is this edge under focus now
  ///
  /// 当前边是否有鼠标浮入
  bool get isHovered => cpn?.isHovered ?? false;
}
