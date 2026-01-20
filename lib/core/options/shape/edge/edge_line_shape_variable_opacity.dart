// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class EdgeLineShapeVariableOpacity extends EdgeLineShape {

  final double? hoverOpacityMultiplier;
  final double normalOpacity;


  EdgeLineShapeVariableOpacity({
    this.hoverOpacityMultiplier,
    this.normalOpacity = 1.0,
    super.decorators
  });


  @override
  Paint getPaint(Edge edge) {
    var paint = Paint();
    // paint.strokeWidth = (edge.isHovered ? 4 : 1.2) / edge.zoom;
    paint.strokeWidth = 1.2 / edge.zoom;
    // paint.strokeWidth = edge.zoom;
    paint.style = PaintingStyle.stroke;
    var startPoint = Offset.zero;
    var endPoint = Offset(edge.length, paint.strokeWidth);
    var hoverOpacity = hoverOpacityMultiplier
        ?? edge.g?.options?.graphStyle.hoverOpacity
        ?? 0.5;
    if (isWeaken(edge)) {
      paint.shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        List.generate(
          2,
              (index) => [
            (edge.start.colors.lastOrNull ?? Colors.white)
                .withValues(alpha: hoverOpacity),
            (edge.end?.colors.lastOrNull ?? Colors.white)
                .withValues(alpha: hoverOpacity)
          ][index],
        ),
      );
    } else {
      paint.shader = ui.Gradient.linear(
        startPoint,
        endPoint,
        List.generate(
          2,
              (index) => [
            (edge.start.colors.lastOrNull ?? Colors.white)
                .withValues(alpha: normalOpacity),
            (edge.end?.colors.lastOrNull ?? Colors.white)
                .withValues(alpha: normalOpacity)
          ][index],
        ),
      );
    }
    return paint;
  }

  @override
  double height(Edge edge) {
    return 3.0;
  }
}
