// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:example/demos/custom_shape_demo/er_graph/schema_vo.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart' show Colors, EdgeInsets;
import 'package:flutter/rendering.dart' as r;
import 'package:flutter_graph_view/flutter_graph_view.dart' hide Vector3;

mixin DashPainter {
  ui.Paint getDashPaint(ui.Offset start, ui.Offset end, Color color,
      {int? specSpace}) {
    var space = specSpace ??
        (((end.dx - start.dx).abs() > (end.dy - start.dy).abs())
                ? (end.dx.toInt() - start.dx.toInt()) ~/ 5
                : (end.dy.toInt() - start.dy.toInt()) ~/ 5)
            .abs();
    return ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = ui.StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(start.toVector2().distanceTo(end.toVector2()), 0),
        List.generate(
          space,
          (index) => [
            color,
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.1),
            Colors.transparent,
          ][index % 4],
        ),
        // 通过 stops 实现虚线效果, 不存在渐变，即第二 Colors.white 跟第一个 Colors.transparent stop 相同
        List.generate(
          space,
          (index) => index % 2 == 0 ? index / space : (index + 1) / space,
        ),
      );
  }
}

class ErGraphConstantsShape extends EdgeShape with DashPainter {
  Color color;

  final EdgeInsets vPadding;

  ErGraphConstantsShape({
    required this.color,
    super.decorators,
    this.vPadding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  });

  List<r.TextPainter> painters = [];
  @override
  ui.Paint getPaint(Edge edge) {
    var c = (edge.data as Constants);
    return getDashPaint(
      Offset.zero,
      Offset(edge.length, 0),
      color,
      specSpace: c.isVirtual ? null : 2,
    );
  }

  @override
  double height(Edge edge) {
    return getPaint(edge).strokeWidth;
  }

  @override
  Vector2 startPosition(Edge edge) {
    var c = (edge.data as Constants);
    TableVo startTable = edge.start.data as TableVo;
    PropertyVo startProp =
        startTable.properties.firstWhere((p) => p.name == c.columnName);
    int startIdx = startTable.properties.indexOf(startProp);
    var painters = edge.g!.extraOnLoad['vertexPainters'][edge.start]
        as List<r.TextPainter>;
    var offset = painters.sublist(0, startIdx + 1).fold(
            0.0, (pre, painter) => pre + painter.height + vPadding.top * 2) +
        painters[startIdx + 1].height / 2 +
        vPadding.top;
    return (-(edge.start.size! / 2).toOffset() + ui.Offset(0, offset))
            .toVector2() +
        edge.start.position;
  }

  @override
  Vector2 endPosition(Edge edge) {
    var c = (edge.data as Constants);
    TableVo endTable = edge.end!.data as TableVo;
    PropertyVo endProp =
        endTable.properties.firstWhere((p) => p.name == c.referencedColumnName);
    var ePainters =
        edge.g!.extraOnLoad['vertexPainters'][edge.end] as List<r.TextPainter>;
    int endIdx = endTable.properties.indexOf(endProp);
    var eOffset = ePainters.sublist(0, endIdx + 1).fold(
            0.0, (pre, painter) => pre + painter.height + vPadding.top * 2) +
        ePainters[endIdx + 1].height / 2 +
        vPadding.top;
    var end = edge.end!.position -
        (edge.end!.size! / 2).toVector2() +
        (ui.Offset(edge.end!.size!.width, eOffset)).toVector2();
    return end;
  }

  @override
  render(
      Edge edge, ui.Canvas canvas, ui.Paint paint, List<ui.Paint> paintLayers) {
    var path = ui.Path();
    path.moveTo(0, paint.strokeWidth / 2);
    path.lineTo(edge.length, paint.strokeWidth / 2);
    canvas.drawPath(path, paint);
    edge.path = path;
    decorators?.forEach((decorator) {
      decorator.decorate(edge, canvas, paint, edge.length, 1);
    });
  }

  @override
  bool? hoverTest(Vector2 position, Edge edge, r.Matrix4 transformMatrix,
      double hoverStrokeWidth) {
    var local = edge.g!.options!.globalToLocal(position);
    var isHover = hoverByPath(local, edge.path!, transformMatrix);
    if (isHover) print('-----------isHover-----------');
    return isHover;
  }
}
