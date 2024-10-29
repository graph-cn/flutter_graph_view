// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

extension RectExt on Rect {
  operator *(double scale) {
    return Rect.fromLTRB(
      center.dx - (center.dx - left) * scale,
      center.dy - (center.dy - top) * scale,
      center.dx + (right - center.dx) * scale,
      center.dy + (bottom - center.dy) * scale,
    );
  }
}

/// Treat the boundary as a spring,
/// so that the node will be repelled by the boundary when it is near the boundary
///
/// 将边界作为一个弹簧，使得节点在边界附近时会受到边界的排斥力
class HookeBorderDecorator extends ForceDecorator {
  double borderFactor;
  double k;

  /// Whether the node is always in the screen as much as possible.
  /// If true, the node will be repelled by the screen boundary.
  /// If false, the node will stop position adjustment when it meets the force balance.
  ///
  /// 节点是否尽可能一直在屏幕内
  /// 如果为true，则节点会受到屏幕边界的排斥力
  /// 如果为false，则节点在遇到力平衡时会停止位置调整
  bool alwaysInScreen;

  Widget Function(HookeBorderDecorator)? handleOverlay;

  @override
  Widget Function()? get verticalOverlay =>
      handleOverlay != null ? () => handleOverlay!(this) : null;

  HookeBorderDecorator({
    this.borderFactor = 0.3,
    this.k = 0.3,
    this.alwaysInScreen = true,
    this.handleOverlay,
    super.decorators,
  });

  Vector2 hooke(Vertex s, Graph graph) {
    var viewport = (alwaysInScreen
            ? s.cpn!.gameRef.camera.visibleWorldRect
            : Rect.fromPoints(Offset.zero, s.cpn!.gameRef.size.toOffset())) *
        borderFactor;
    var widthScale = 0;
    var p = s.cpn!.position;
    double fx = 0;
    double fy = 0;
    if (p.x < viewport.left + widthScale) {
      fx = viewport.left + widthScale - p.x;
    } else if (p.x > viewport.right - widthScale) {
      fx += (viewport.right - widthScale) - p.x;
    }

    if (p.y < viewport.top + widthScale) {
      fy = viewport.top + widthScale - p.y;
    } else if (p.y > viewport.bottom - widthScale) {
      fy += (viewport.bottom - widthScale) - p.y;
    }
    return Vector2(fx * k, fy * k);
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    if (v.position != Vector2.zero()) {
      var force = hooke(v, graph);
      setForceMap(v, v, force);
    }
  }
}
