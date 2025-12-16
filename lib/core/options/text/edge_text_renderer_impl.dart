// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default title renderer impl.
///
/// 默认的标题渲染器实现
class EdgeTextRendererImpl extends EdgeTextRenderer {
  EdgeTextRendererImpl({super.shape});
  @override
  void render(Edge edge, ui.Canvas canvas, ui.Paint paint) {
    canvas.save();
    canvas.transform(edge.edgeCenter());
    var zoom = edge.zoom;
    TextStyle? edgeTextStyle =
        edge.g?.options?.graphStyle.edgeTextStyleGetter?.call(edge, shape);
    var text = edge.g?.options?.edgeTextGetter.call(edge) ?? '';

    TextStyle textStyle = super.textStyleGetter(
      edgeTextStyle,
      paint,
      scale: 1 / zoom,
      isLoop: edge.isLoop,
      textLen: text.length,
      distance: edge.length,
    );

    final paragraph = super.paragraph(textStyle, paint, text);

    var tw = paragraph.width;
    ui.Offset offset = edge.isLoop
        ? ui.Offset(-tw / 2, -paragraph.height)
        : ui.Offset(-tw / 2, -paragraph.height / 2);

    /// 6.绘制
    canvas.drawParagraph(paragraph, offset);
    canvas.restore();
  }
}
