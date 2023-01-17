// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class VertexComponent extends CircleComponent with TapCallbacks, Hoverable {
  late Vertex vertex;
  ValueNotifier<double>? scaleNotifier;
  static const speed = 3;

  static const indicatorSize = 6.0;

  VertexComponent(this.vertex)
      : super(
          position: vertex.position,
          radius: vertex.radius,
          anchor: Anchor.center,
        );
  int count = 0;
  double offsetX = 0;
  double offsetY = 0;

  bool breathDirect = false;

  @override
  Future<void> onLoad() {
    breathDirect = math.Random().nextBool();
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (count % 150 == 0) {
      breathDirect = !breathDirect;
      offsetY = (breathDirect ? 1 : -1) * .1;
    }
    // offsetX =
    //     (math.Random().nextBool() ? 1 : -1) * math.Random().nextDouble() * .8;
    vertex.position.x += offsetX;
    vertex.position.y += offsetY;
    position = vertex.position;
    double scaleV = scaleNotifier?.value ?? 1.0;
    scale = Vector2(scaleV, scaleV);
    angle += speed * dt * (isHovered ? 0 : 3);
    angle %= 2 * math.pi;
    count++;
  }

  @override
  get paint => Paint()
    ..shader = ui.Gradient.radial(
        Offset(vertex.radius, vertex.radius), vertex.radius, vertex.colors);

  @override
  bool onHoverEnter(PointerHoverInfo info) {
    info.handled = true;
    return super.onHoverEnter(info);
  }

  @override
  bool onHoverLeave(PointerHoverInfo info) {
    info.handled = false;
    return super.onHoverLeave(info);
  }

  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}
