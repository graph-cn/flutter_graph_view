// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';
import 'dart:math';

import 'package:example/demos/custom_shape_demo/er_graph/connect_component.dart';
import 'package:example/demos/custom_shape_demo/er_graph/schema_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ErGraphTableComponent extends VertexComponent {
  ErGraphTableComponent(
    super.vertex,
    super.graph,
    super.context,
    super.algorithm, {
    super.options,
    super.graphComponent,
  }) {
    assert(vertex.data is TableVo);
    var table = vertex.data as TableVo;
    var width = table.properties.fold(textPainter(table.name).width,
        (previousValue, element) {
      return max(
          previousValue,
          textPainter(
                  "${element.name} ${element.type}${element.length != null ? '(${element.length})' : ''}")
              .width);
    });
    super.size = Vector2(
      width,
      propertiesHeight * table.properties.length + titleHeight.toDouble(),
    );
    print(size);
  }

  TextPainter textPainter(String text) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 27),
        text: text,
      ),
    )..layout();
  }

  int propertiesHeight = 36;
  int titleHeight = 36;

  @override
  FutureOr<void> onLoad() {
    assert(vertex.data is TableVo);
    var table = vertex.data as TableVo;
    add(RectangleComponent(
      paint: Paint()..color = Colors.red.withAlpha(189),
      position: Vector2.zero(),
      size: Vector2(size.x, titleHeight.toDouble()),
      anchor: Anchor.topLeft,
      priority: 0,
    )..add(TextComponent(
        text: table.name,
        position: Vector2(size.x / 2, titleHeight / 2),
        size: Vector2(size.x, titleHeight.toDouble()),
        anchor: Anchor.center,
        priority: 1,
      )));
    table.properties.forEach((p) {
      var propCpn = RectangleComponent(
        paint: Paint()..color = Colors.blue.withAlpha(189),
        position: Vector2(
            -0.5,
            table.properties.indexOf(p) * (propertiesHeight - 1) +
                propertiesHeight.toDouble()),
        size: Vector2(size.x, propertiesHeight.toDouble()),
        anchor: Anchor.topLeft,
        priority: 0,
      )..add(TextComponent(
          text: "${p.name} ${p.type}${p.length != null ? '(${p.length})' : ''}",
          position: Vector2(16, propertiesHeight.toDouble() / 2),
          anchor: Anchor.centerLeft,
          priority: 1,
        ));
      // 为属性添加背景
      add(propCpn);

      propCpn.add(ConnectComponent(
          data: vertex,
          onConnect: (start, end) {
            print("连接 $start -> $end");
          }));
    });
    algorithmOnLoad(algorithm);
    loadOverlay();
    return super.onLoad();
  }

  // @override
  // ShapeHitbox get hitBox => RectangleHitbox(
  //       size: Vector2.zero(),
  //       isSolid: true,
  //       position: position,
  //       anchor: anchor,
  //     );

  @override
  void render(Canvas canvas) {}

  @override
  vertexUpdate() {
    vertex.radius = 50;
    algorithm.$size.value = Size(game.size.x, game.size.y);

    algorithmCompute(algorithm);
    hitBox?.position = position;
    if (hitBox != null) vertexShape.updateHitBox(vertex, hitBox!);
    vertexShape.setPaint(vertex);

    position.x = vertex.position.x;
    position.y = vertex.position.y;
  }
}
