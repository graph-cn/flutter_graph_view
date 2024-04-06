// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Used to render the vertex text.
///
/// 用于渲染节点的标题
abstract class VertexTextRenderer {
  VertexShape? shape;

  VertexTextRenderer({this.shape});
  void render(Vertex<dynamic> vertex, Canvas canvas, Paint paint);
}
