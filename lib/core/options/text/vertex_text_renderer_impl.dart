// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default title renderer impl.
///
/// 默认的标题渲染器实现
class VertexTextRendererImpl extends VertexTextRenderer {
  @override
  void render(Vertex<dynamic> vertex, ui.Canvas canvas, ui.Paint paint) {
    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    final paragraphStyle = ui.ParagraphStyle(
      fontSize: 14,
    );

    /// 2.根据 ParagraphStyle 生成 ParagraphBuilder
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
    var zoom = vertex.cpn!.game.camera.viewfinder.zoom;
    var text = vertex.cpn?.options?.textGetter.call(vertex) ?? '';

    /// 3.添加样式和文字
    paragraphBuilder
      ..pushStyle(ui.TextStyle(
        fontSize: 16 / zoom,
        foreground: paint,
      ))
      ..addText(text);

    /// 4.通过 build 取到 Paragraph
    final paragraph = paragraphBuilder.build();

    TextPainter hpainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 16),
        text: text,
      ),
    )..layout();

    /// 5.根据宽高进行布局layout
    paragraph
        .layout(ui.ParagraphConstraints(width: hpainter.width / zoom * 1.1));

    /// 6.绘制
    canvas.drawParagraph(
        paragraph,
        ui.Offset(
          -hpainter.width / zoom / 2.5,
          -vertex.radiusZoom - 20 / zoom,
        ));
  }
}
