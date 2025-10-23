// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui' as ui;

import 'package:example/demos/custom_shape_demo/er_graph/er_graph_constants_shape.dart';
import 'package:flutter/rendering.dart' as r;
import 'package:example/demos/custom_shape_demo/er_graph/schema_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart' hide Vector3;
import 'package:vector_math/vector_math_64.dart' as vm64;

class ErGraphTableShape extends VertexShape with DashPainter {
  Color background = Colors.blue.shade900;
  Color propBackground = Colors.black;
  ErGraphTableShape({this.lineColor = Colors.white});
  Color lineColor;
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 8);

  late Graph graph;

  @override
  void onLoad(Graph graph) {
    this.graph = graph;
    Map<Vertex, List<r.TextPainter>> vertexPainters = {};
    graph.extraOnLoad['vertexPainters'] = vertexPainters;
    Map<Vertex, double> vertexWidth = {};
    graph.extraOnLoad['vertexWidth'] = vertexWidth;
    Map<Vertex, double> vertexHeight = {};
    graph.extraOnLoad['vertexHeight'] = vertexHeight;

    for (var v in graph.vertexes) {
      List<r.TextPainter> painters = [];
      var titlePainter = textPainter(v.data.name, v);
      painters.add(titlePainter);
      var maxWidth = titlePainter.width;
      maxWidth = titlePainter.width;
      var height = titlePainter.height + padding.top * 2;
      for (var p in (v.data as TableVo).properties) {
        var propPainter = textPainter(propText(p), v);
        painters.add(propPainter);
        if (propPainter.width > maxWidth) maxWidth = propPainter.width;
        height += propPainter.height + padding.top * 2;
      }
      vertexWidth[v] = maxWidth + padding.left * 2;
      vertexHeight[v] = height;
      vertexPainters[v] = painters;
    }
  }

  String propText(PropertyVo p) {
    return '${p.name} ${p.type}${p.length != null ? '(${p.length})' : ''}';
  }

  @override
  double height(Vertex vertex) {
    return vertex.size!.height * vertex.g!.options!.scale.value;
  }

  @override
  double width(Vertex vertex) {
    return vertex.size!.width * vertex.g!.options!.scale.value;
  }

  Vertex? startVertex;
  Vertex? endVertex;
  PropertyVo? start;
  PropertyVo? end;

  PropertyVo? temp;
  late Canvas canvas;
  late ui.Paint paint;

  Rect? rect;

  Map<PropertyVo, List<Rect>> propRect = {};

  @override
  bool onDrag(Vector2 delta) {
    if (start == null) return false;
    var matrix = transformMatrix(startVertex!);
    var pointer =
        globalToVertex(startVertex!, startVertex!.g!.options!.pointer, matrix);
    rect = pointer.distanceTo(propRect[start]!.first.center.toVector2()) <
            pointer.distanceTo(propRect[start]!.last.center.toVector2())
        ? propRect[start]!.first
        : propRect[start]!.last;
    return true;
  }

  @override
  void onPointerUp(PointerUpEvent e) {
    if (start != null && temp != null) {
      graph.mergeGraph([
        [],
        [
          Constants(
            schema: (startVertex!.data as TableVo).db?.name ?? '',
            name: 'product_ibfk_1',
            tableSchema: 'tmalldemodb',
            referencedTableName: (startVertex!.data as TableVo).name,
            referencedColumnName: start!.name,
            referencedTableSchema: 'tmalldemodb',
            tableName: endVertex!.data.name,
            columnName: temp!.name,
          )
        ]
      ]);
    }

    start = null;
    end = null;
    temp = null;
    startVertex = null;
    endVertex = null;
    rect = null;
  }

  @override
  void onPointerDown(PointerDownEvent e) {
    if (temp != null) start = temp;
    temp = null;
  }

  @override
  render(Vertex vertex, ui.Canvas canvas, ui.Paint paint,
      List<ui.Paint> paintLayers) {
    this.canvas = canvas;
    this.paint = paint;
    var table = vertex.data as TableVo;
    var painters =
        vertex.g!.extraOnLoad['vertexPainters'][vertex] as List<TextPainter>;
    var width = vertex.g!.extraOnLoad['vertexWidth'][vertex];
    var height = vertex.g!.extraOnLoad['vertexHeight'][vertex];

    /// 0. 绘制背景板
    paint
      ..shader = null
      ..color =
          vertex.isHovered ? background : background.withValues(alpha: 0.3);

    vertex.size = Size(width, height);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    var textStyle =
        graph.options!.graphStyle.vertexTextStyleGetter?.call(vertex, this);
    final paragraphStyle = ui.ParagraphStyle(
      fontSize: textStyle!.fontSize,
      fontFamily: textStyle.fontFamily,
    );

    /// 2.根据 ParagraphStyle 生成 ParagraphBuilder
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
    var title = "${vertex.data.name}";

    paint.color = textStyle.color ?? vertex.colors.first;

    /// 3.添加样式和文字
    paragraphBuilder
      ..pushStyle(ui.TextStyle(foreground: paint))
      ..addText(title);

    /// 4.通过 build 取到 Paragraph
    final paragraph = paragraphBuilder.build();

    TextPainter hpainter = textPainter(title, vertex);

    /// 5.根据宽高进行布局layout
    paragraph.layout(ui.ParagraphConstraints(width: hpainter.width * 1.1));

    /// 6.绘制
    canvas.drawParagraph(paragraph, ui.Offset((width - hpainter.width) / 2, 3));

    var yOffset = painters[0].height + padding.top * 2;
    for (var i = 0; i < table.properties.length; i++) {
      var prop = table.properties[i];
      var painter = painters[i + 1];
      drawProp(
          vertex, paint, yOffset, painter, prop, textStyle, paragraphStyle);
      yOffset += painter.height + padding.top * 2;
    }
  }

  void drawProp(
    Vertex vertex,
    ui.Paint paint,
    double yOffset,
    TextPainter painter,
    PropertyVo prop,
    TextStyle textStyle,
    ui.ParagraphStyle paragraphStyle,
  ) {
    var width = graph.extraOnLoad['vertexWidth'][vertex];
    var matrix = transformMatrix(vertex);

    paint.color = propBackground.withValues(alpha: 0.3);
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        yOffset,
        width,
        painter.height + padding.top * 2 - 1,
      ),
      paint,
    );

    var left = Rect.fromCenter(
      center: Offset(0, yOffset + (painter.height + padding.top * 2 - 1) / 2),
      width: 8,
      height: 8,
    );
    var right = left.translate(width, 0);

    var localPoint =
        vertex.g!.options!.globalToLocal(vertex.g!.options!.pointer).toOffset();

    Rect leftHitBox = toHitBox(vertex, left, matrix);

    var rightHitBox = toHitBox(vertex, right, matrix);
    propRect[prop] = [left, right];
    var leftHover = leftHitBox.contains(localPoint);
    var rightHover = rightHitBox.contains(localPoint);
    if (leftHover || rightHover) {
      if (start == null && temp == null) {
        temp = prop;
        startVertex = vertex;
      }
      if (start != null) {
        temp = prop;
        endVertex = vertex;
      }
    } else if (temp == prop) {
      temp = null;
    }

    if (rect != null && startVertex == vertex) {
      var s = rect!.center;
      var e = globalToVertex(vertex, startVertex!.g!.options!.pointer, matrix)
          .toOffset();
      var dashPaint = getDashPaint(e, s, lineColor);
      canvas.drawLine(s, e, dashPaint);
    }
    var c = paint.color;
    paint.color = leftHover || start == prop
        ? Colors.white
        : Colors.white.withValues(alpha: 0.3);
    canvas.drawRect(left, paint);
    paint.color = rightHover || start == prop
        ? Colors.white
        : Colors.white.withValues(alpha: 0.3);
    canvas.drawRect(right, paint);
    paint.color = textStyle.color ?? c;

    var propTxt = propText(prop);

    /// 5.根据宽高进行布局layout
    var propBuilder = ui.ParagraphBuilder(paragraphStyle);
    final propPara = (propBuilder
          ..pushStyle(ui.TextStyle(foreground: paint))
          ..addText(propTxt))
        .build();
    propPara.layout(ui.ParagraphConstraints(width: painter.width * 1.1));

    /// 6.绘制
    canvas.drawParagraph(
        propPara, ui.Offset(padding.left, yOffset + padding.top - 1));
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

  TextPainter textPainter(String text, Vertex vertex) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: vertex.g!.options!.graphStyle.vertexTextStyleGetter
            ?.call(vertex, this),
        text: text,
      ),
    )..layout();
  }

  @override
  bool hoverTest(Vertex v) {
    var p = v.g!.options!.pointer;
    return Rect.fromCenter(
      center: v.g!.options!.localToGlobal(v.position).toOffset(),
      width: width(v),
      height: height(v),
    ).contains(p.toOffset());
  }

  ui.Rect toHitBox(Vertex v, ui.Rect left, r.Matrix4 matrix) {
    var inVertex =
        matrix.transform3(vm64.Vector3(left.center.dx, left.center.dy, 0));
    return ui.Rect.fromCenter(
      center: Offset(inVertex.x, inVertex.y),
      width: 8,
      height: 8,
    );
  }

  Vector2 globalToVertex(Vertex v, Vector2 vec, r.Matrix4 matrix) {
    var invert = r.Matrix4.tryInvert(matrix);
    if (invert == null) return Vector2.zero();
    var local = v.g!.options!.globalToLocal(vec);
    var inVertex = invert.transform3(vm64.Vector3(local.x, local.y, 0));
    return Vector2(inVertex.x, inVertex.y);
  }
}
