// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';

import 'package:example/demos/custom_shape_demo/er_graph/schema_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ErLayoutComponent extends VertexComponent {
  ErLayoutComponent(
    super.vertex,
    super.graph,
    super.context,
    super.algorithm, {
    super.options,
    super.graphComponent,
  }) {
    assert(vertex.data is TableVo);
  }

  @override
  FutureOr<void> onLoad() {
    assert(vertex.data is TableVo);
    algorithmOnLoad(algorithm);
    loadOverlay();
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    Future.delayed(Duration.zero, () {
      if (hasPanel) {
        game.overlays.remove(overlayName);
        game.overlays.add(overlayName);
      }
    });
  }
}
