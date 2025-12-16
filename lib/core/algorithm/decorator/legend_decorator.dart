// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class LegendDecorator extends GraphAlgorithm {
  Widget Function(LegendDecorator)? handleOverlay;

  @override
  Widget Function()? get leftOverlay => () => handleOverlay!(this);

  LegendDecorator({
    this.handleOverlay,
    super.decorators,
  }) {
    handleOverlay = handleOverlay ?? kLegendOverlayBuilder();
  }

  final List<String> hiddenTags = [];
  final List<String> hiddenEdges = [];

  void changeTag(String tag) {
    if (hiddenTags.contains(tag)) {
      hiddenTags.remove(tag);
    } else {
      hiddenTags.add(tag);
    }
  }

  void changeEdge(String edge) {
    if (hiddenEdges.contains(edge)) {
      hiddenEdges.remove(edge);
    } else {
      hiddenEdges.add(edge);
    }
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    var isHidden = false;
    v.tags?.forEach((tag) {
      isHidden |= hiddenTags.contains(tag);
    });
    if (isHidden) {
      v.visible = false;
      for (var e in v.neighborEdges) {
        e.visible = false;
      }
    } else {
      v.visible = true;
    }
    for (var e in graph.edges) {
      if (!hiddenEdges.contains(e.edgeName)) {
        e.visible = true;
      } else {
        e.visible = false;
      }
    }
  }
}
