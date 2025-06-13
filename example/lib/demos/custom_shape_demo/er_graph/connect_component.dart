// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:ui' as ui;

import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ConnectComponent extends PositionComponent {
  ConnectComponent({
    super.anchor = Anchor.center,
    super.position,
    super.priority = 3,
    this.data,
    this.onConnect,
  });

  dynamic data;
  Function(dynamic, dynamic)? onConnect;

  PositionComponent get parent2 => parent as PositionComponent;

  ConnectPoint? leftPoint;
  ConnectPoint? rightPoint;

  @override
  onLoad() async {
    super.onLoad();
    // 设置组件的碰撞盒
    add(leftPoint ??= ConnectPoint(
      position: Vector2(0, parent2.size.y / 2),
      data: data,
      onConnect: onConnect,
    ));
    add(rightPoint ??= ConnectPoint(
      position: Vector2(parent2.size.x, parent2.size.y / 2),
      data: data,
      onConnect: onConnect,
    ));
  }
}

class ConnectPoint extends CircleComponent with HoverCallbacks, DragCallbacks {
  static ConnectPoint? start;
  static ConnectPoint? end;
  static Set<ConnectPoint> allConnectPoints = {};

  static Vector2? mousePosition;

  static Vector2? mouseOffset;

  Canvas? canvas;

  dynamic data;

  Function(dynamic, dynamic)? onConnect;

  ConnectPoint({
    super.paint,
    super.anchor = Anchor.center,
    super.position,
    super.radius = 4,
    super.priority = 5,
    this.data,
    this.onConnect,
  }) {
    allConnectPoints.add(this);
  }

  PositionComponent get parent2 => parent as PositionComponent;

  @override
  onLoad() async {
    super.onLoad();
    // 设置组件的大小
    size = Vector2(radius * 2, radius * 2);
  }

  @override
  void render(Canvas canvas) {
    size = Vector2(radius * 2, radius * 2);
    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // 画个边框
    if (isHovered || start == this || end == this) {
      canvas.drawCircle(
        Offset(radius, radius),
        radius,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (mousePosition != null && start == this) {
      // 画个线条连接起始点和当前点，虚线、折线
      var endPosition = mousePosition! + mouseOffset!;
      canvas.drawPath(
        Path()
          ..moveTo(radius, radius)
          ..lineTo(endPosition.x, endPosition.y)
          ..fillType = PathFillType.evenOdd,
        getDashPaint(
          Offset(radius, radius),
          endPosition.toOffset(),
        ),
      );
    }
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    // 记录起始点
    mousePosition = Vector2(radius, radius);
    mouseOffset = event.localPosition - Vector2(radius, radius);
    start = this;
    end = null; // 清除结束点
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    // 更新位置
    mousePosition = mousePosition! + event.localDelta;

    end = allConnectPoints
        .where((cp) => cp.containsPoint(
            absolutePositionOf(mousePosition! + Vector2(radius, radius))))
        // ignore: sdk_version_since
        .firstOrNull;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (start == null || end == null) {
      reset();
    } else {
      add(ConnectLine(
        start: start!,
        end: end!,
      ));
      onConnect?.call(start?.data, end?.data);
      reset();
    }
  }

  reset() {
    // 清除起始点
    start = null;
    end = null;
    mousePosition = null;
  }

  @override
  void onHoverEnter() {
    super.onHoverEnter();
    FlutterGraphWidget.stopDrag = true;
    start = this;
  }

  @override
  void onHoverExit() {
    super.onHoverExit();
    FlutterGraphWidget.stopDrag = false;
    reset();
  }

  @override
  void onPointerMove(event) {
    super.onPointerMove(event);
    if (start != null && mousePosition != null) {
      end = this;
    }
  }

  Paint getDashPaint(Offset start, Offset end) {
    int space = (((end.dx - start.dx).abs() > (end.dy - start.dy).abs())
            ? (end.dx.toInt() - start.dx.toInt()) ~/ 5
            : (end.dy.toInt() - start.dy.toInt()) ~/ 5)
        .abs();
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        start,
        end,
        List.generate(
          space,
          (index) => [
            Colors.white,
            Colors.white,
            Colors.transparent,
            Colors.transparent,
          ][index % 4],
        ),
        // 通过 stops 实现虚线效果, 不存在渐变，即第二 Colors.white 跟第一个 Colors.transparent stop 相同
        List.generate(
          space,
          (index) => index % 2 == 0 ? index / space : (index + 1) / space,
        ),
      );
  }
}

class ConnectLine extends PositionComponent {
  ConnectLine({
    super.anchor = Anchor.center,
    super.position,
    super.priority = 3,
    required this.start,
    required this.end,
  });

  ConnectPoint start;
  ConnectPoint end;

  Path get path {
    return Path()
      ..moveTo(startPosition.dx, startPosition.dy)
      ..lineTo(endPosition.dx, endPosition.dy);
  }

  Offset get startPosition {
    return Offset(start.radius, start.radius);
  }

  Offset get endPosition {
    return Offset(
          end.parent2.absolutePositionOf(end.position).x + end.radius,
          end.parent2.absolutePositionOf(end.position).y + end.radius,
        ) -
        Offset(
          start.parent2.absolutePositionOf(start.position).x,
          start.parent2.absolutePositionOf(start.position).y,
        );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawPath(
      path,
      start.getDashPaint(startPosition, endPosition),
    );
  }
}
