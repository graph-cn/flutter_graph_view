// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default edge shape impl.
///
/// 默认使用 直线做边。
class EdgeLineShape extends EdgeShape {
  @override
  render(Edge edge, Canvas canvas, Paint paint, List<Paint> paintLayers) {
    paint.strokeWidth = edge.isHovered ? 3 : 1;

    var startPoint = Offset.zero;
    var endPoint = Offset(len(edge), 0);
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  void setPaint(Edge edge) {
    if (isWeaken(edge)) {
      edge.cpn!.paint = Paint()..color = Colors.white.withOpacity(0);
    } else {
      edge.cpn!.paint = Paint()..color = Colors.white;
    }
  }

  @override
  double height(Edge edge) {
    return 1.0;
  }
}
