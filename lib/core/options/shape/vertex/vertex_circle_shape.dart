// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default shape impl.
///
/// 默认使用 圆型做节点。
class VertexCircleShape extends VertexShape {
  VertexCircleShape({VertexTextRenderer? textRenderer}) {
    super.textRenderer = textRenderer ?? VertexTextRendererImpl();
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, paint, paintLayers) {
    canvas.drawCircle(
      ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
      vertex.radiusZoom,
      paint,
    );
    // 渲染标题
    if (vertex.cpn?.options?.showText ??
        true && vertex.cpn!.game.camera.viewfinder.zoom > 0.3) {
      textRenderer?.render(vertex, canvas, paint);
    }
  }

  @override
  double height(Vertex vertex) {
    return vertex.radiusZoom * 2;
  }

  @override
  double width(Vertex vertex) {
    return vertex.radiusZoom * 2;
  }

  @override
  ShapeHitbox hitBox(Vertex vertex, ShapeComponent cpn) {
    return CircleHitbox(
      isSolid: true,
      position: cpn.position,
      anchor: cpn.anchor,
    );
  }

  @override
  void updateHitBox(Vertex vertex, ShapeHitbox hitBox) {
    hitBox as CircleHitbox;
    hitBox.radius = vertex.radiusZoom * 2;
  }

  @override
  void setPaint(Vertex vertex) {
    var cpn = vertex.cpn!;
    var colors = vertex.colors;

    if (isWeaken(vertex)) {
      cpn.paint = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
          vertex.radiusZoom,
          List.generate(
            colors.length,
            (index) => colors[index].withOpacity(.5),
          ),
          List.generate(colors.length, (index) => (index + 1) / colors.length),
        );
    } else {
      cpn.paint = ui.Paint()
        ..shader = ui.Gradient.radial(
          ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
          vertex.radiusZoom,
          colors,
          List.generate(colors.length, (index) => (index + 1) / colors.length),
        );
    }
  }
}

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
