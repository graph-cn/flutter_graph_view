// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

/// Used to render the text.
///
/// 用于渲染文本
abstract class TextRenderer {
  ui.ParagraphStyle paragraphStyle(TextStyle? textStyle, Paint paint) {
    textStyle = textStyle ?? textStyleGetter(textStyle, paint);

    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    final paragraphStyle = ui.ParagraphStyle(
      fontSize: textStyle.fontSize,
      fontWeight: textStyle.fontWeight,
      fontFamily: textStyle.fontFamily,
      fontStyle: textStyle.fontStyle,
    );
    return paragraphStyle;
  }

  TextStyle textStyleGetter(
    TextStyle? textStyle,
    Paint paint, {
    double scale = 1.0,
    bool isLoop = false,
    int? textLen,
    double? distance,
  }) {
    var fontSize = (textStyle?.fontSize ?? 14) * scale;
    var fontWeight = textStyle?.fontWeight ?? FontWeight.normal;
    if (!isLoop && textLen != null && distance != null && distance > 0) {
      var overflow = textLen * fontSize * 0.7 > distance;
      if (overflow) {
        fontSize = distance / textLen / 0.7;
        fontWeight = FontWeight.w100;
      }
    }
    var fontColor = textStyle?.color;
    var backgroundColor = textStyle?.backgroundColor;
    return TextStyle(
      fontSize: min(fontSize, 18),
      foreground: fontColor != null ? (Paint()..color = fontColor) : paint,
      fontWeight: fontWeight,
      background:
          backgroundColor == null ? null : (Paint()..color = backgroundColor),
      fontFamily: textStyle?.fontFamily,
      fontStyle: textStyle?.fontStyle,
    );
  }

  ui.Paragraph paragraph(TextStyle textStyle, ui.Paint paint, String text) {
    /// 1.生成 ParagraphStyle，可设置文本的基本信息
    final paragraphStyle = this.paragraphStyle(textStyle, paint);

    /// 2.根据 ParagraphStyle 生成 ParagraphBuilder
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);

    /// 3.添加样式和文字
    paragraphBuilder
      ..pushStyle(textStyle.getTextStyle())
      ..addText(text);

    /// 4.通过 build 取到 Paragraph
    final paragraph = paragraphBuilder.build();

    TextPainter hpainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      text: TextSpan(style: textStyle, text: text),
    )..layout();

    /// 5.根据宽高进行布局layout
    paragraph.layout(ui.ParagraphConstraints(width: hpainter.width));
    return paragraph;
  }
}
