// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ErGraphTableShape extends VertexShape {
  @override
  double height(Vertex vertex) {
    return vertex.size!.height;
  }

  @override
  double width(Vertex vertex) {
    return vertex.size!.width;
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, ui.Paint paint,
      List<ui.Paint> paintLayers) {
    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    final paragraphStyle = ui.ParagraphStyle(
      fontSize: 14,
    );

    /// 2.根据 ParagraphStyle 生成 ParagraphBuilder
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
    var text = "${vertex.data.name}";

    /// 3.添加样式和文字
    paragraphBuilder
      ..pushStyle(ui.TextStyle(
        fontSize: 14,
        foreground: paint,
      ))
      ..addText(text);

    /// 4.通过 build 取到 Paragraph
    final paragraph = paragraphBuilder.build();

    TextPainter hpainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        text: text,
      ),
    )..layout();

    /// 5.根据宽高进行布局layout
    paragraph.layout(ui.ParagraphConstraints(width: hpainter.width * 1.1));

    /// 6.绘制
    canvas.drawParagraph(paragraph, const ui.Offset(6, 3));
  }

  @override
  Paint getPaint(Vertex vertex) {
    var colors = vertex.colors;

    return ui.Paint()
      ..shader = ui.Gradient.radial(
        ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
        vertex.radiusZoom,
        colors,
        List.generate(colors.length, (index) => (index + 1) / colors.length),
      );
  }
}
