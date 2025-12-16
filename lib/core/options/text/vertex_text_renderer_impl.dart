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
  VertexTextRendererImpl({super.shape});
  @override
  void render(Vertex<dynamic> vertex, ui.Canvas canvas, ui.Paint paint) {
    var zoom = vertex.zoom;
    TextStyle? vertexTextStyle = vertex
        .g?.options?.graphStyle.vertexTextStyleGetter
        ?.call(vertex, shape);
    var text = vertex.g?.options?.textGetter.call(vertex) ?? '';

    TextStyle textStyle =
        super.textStyleGetter(vertexTextStyle, paint, scale: 1 / zoom);

    final paragraph = super.paragraph(textStyle, paint, text);

    var tw = paragraph.width;
    var vw = vertex.radiusZoom;

    /// 6.绘制
    canvas.drawParagraph(
        paragraph, ui.Offset(-tw / 2, -vw - textStyle.fontSize! / 0.7));
  }
}
