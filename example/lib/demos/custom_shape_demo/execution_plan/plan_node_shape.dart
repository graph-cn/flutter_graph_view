// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;

// ignore: depend_on_referenced_packages
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The default shape impl.
///
/// 默认使用 圆型做节点。
class PlanNodeShape extends VertexShape {
  PlanNodeShape({VertexTextRenderer? textRenderer}) {
    super.textRenderer = textRenderer ?? VertexTextRendererImpl();
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, paint, paintLayers) {
    vertex.cpn?.anchor = Anchor.center;
    var originShader = paint.shader;
    canvas.drawRRect(
        RRect.fromLTRBR(0, 0, vertex.size!.width, vertex.size!.height + 10,
            const Radius.circular(3)),
        paint);
    paint.shader = ui.Gradient.radial(
      ui.Offset(vertex.radiusZoom, vertex.radiusZoom),
      vertex.radiusZoom,
      [Colors.black, Colors.black],
    );
    canvas.drawRRect(
        RRect.fromLTRBR(3, 3, vertex.size!.width - 3,
            vertex.size!.height - 3 + 10, const Radius.circular(2.4)),
        paint);
    paint.shader = originShader;
    // 渲染标题
    if (vertex.cpn?.options?.showText ??
        true && vertex.cpn!.game.camera.viewfinder.zoom > 0.3) {
      textRenderer?.render(vertex, canvas, paint);
    }
  }

  @override
  double height(Vertex vertex) {
    return vertex.size!.height;
  }

  @override
  double width(Vertex vertex) {
    return vertex.size!.width;
  }

  @override
  ShapeHitbox hitBox(Vertex vertex, ShapeComponent cpn) {
    return RectangleHitbox(
      size: Vector2.zero(),
      isSolid: true,
      position: cpn.position,
      anchor: cpn.anchor,
    );
  }

  @override
  void updateHitBox(Vertex vertex, ShapeHitbox hitBox) {
    // hitBox as RectangleHitbox;
    // hitBox.size = vertex.cpn?.size ?? Vector2.zero();
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
    var text =
        "${vertex.data.name}_${vertex.data.id}\n${outputVar(vertex)}\n${inputVar(vertex)}";

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

  String outputVar(Vertex vertex) {
    return "outputVar: ${vertex.data.outputVar}";
  }

  String inputVar(Vertex vertex) {
    return "inputVar: ${vertex.data.inputVar}";
  }
}
