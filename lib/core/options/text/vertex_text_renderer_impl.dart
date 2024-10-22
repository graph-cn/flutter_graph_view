// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default title renderer impl.
///
/// 默认的标题渲染器实现
class VertexTextRendererImpl extends VertexTextRenderer {
  VertexTextRendererImpl({VertexShape? shape}) : super(shape: shape);
  @override
  void render(Vertex<dynamic> vertex, ui.Canvas canvas, ui.Paint paint) {
    TextStyle? vertexTextStyle = vertex
        .cpn?.options?.graphStyle.vertexTextStyleGetter
        ?.call(vertex, shape);

    var paragraphFontSize = vertexTextStyle?.fontSize ?? 14;
    var fontWeight = vertexTextStyle?.fontWeight ?? FontWeight.normal;
    var fontColor = vertexTextStyle?.color;
    var backgroundColor = vertexTextStyle?.backgroundColor;

    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    final paragraphStyle = ui.ParagraphStyle(
      fontSize: paragraphFontSize,
      fontWeight: fontWeight,
    );

    /// 2.根据 ParagraphStyle 生成 ParagraphBuilder
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
    var zoom = vertex.cpn!.game.camera.viewfinder.zoom;
    var text = vertex.cpn?.options?.textGetter.call(vertex) ?? '';

    var fontSize = (paragraphFontSize + 2) / zoom;

    ui.TextStyle? textStyle = ui.TextStyle(
      fontSize: fontSize,
      foreground: fontColor != null ? (Paint()..color = fontColor) : paint,
      fontWeight: fontWeight,
      background:
          backgroundColor == null ? null : (Paint()..color = backgroundColor),
    );

    /// 3.添加样式和文字
    paragraphBuilder
      ..pushStyle(textStyle)
      ..addText(text);

    /// 4.通过 build 取到 Paragraph
    final paragraph = paragraphBuilder.build();

    TextPainter hpainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style:
            TextStyle(fontSize: paragraphFontSize + 2, fontWeight: fontWeight),
        text: text,
      ),
    )..layout();

    /// 5.根据宽高进行布局layout
    paragraph
        .layout(ui.ParagraphConstraints(width: hpainter.width / zoom * 1.1));

    var tw = paragraph.width;
    var vw = vertex.cpn!.size.x;

    /// 6.绘制
    canvas.drawParagraph(
        paragraph,
        ui.Offset(
          (vw - tw) / 2,
          -vertex.radiusZoom - 20 / zoom,
        ));
  }
}
