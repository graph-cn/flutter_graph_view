// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Used to render the edge text.
///
/// 用于渲染边的标题
abstract class EdgeTextRenderer extends TextRenderer {
  EdgeShape? shape;

  EdgeTextRenderer({this.shape});
  void render(Edge edge, Canvas canvas, Paint paint);
}
