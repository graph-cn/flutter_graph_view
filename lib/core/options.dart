// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/cupertino.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The core api for Graph Options.
///
/// 图配置项
class Options {
  /// The builder of the vertex panel, triggered when the mouse hovers.
  ///
  /// 顶点数据面板的构建器，鼠标悬停到对应节点时触发。
  Widget Function(Vertex hoverVertex)? vertexPanelBuilder;

  /// The builder of the edge data panel, triggered when the mouse hovers.
  ///
  /// 边数据面板的构建器，鼠标悬停到对应节点时触发。
  Widget Function(Edge hoverVertex)? edgePanelBuilder;
}
