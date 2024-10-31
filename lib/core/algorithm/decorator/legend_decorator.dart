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
    List<GraphAlgorithm>? decorators,
  }) : super(decorators: decorators) {
    handleOverlay = handleOverlay ?? kLegendOverlayBuilder();
  }

  final List<String> hiddenTags = [];
  final List<String> hiddenEdges = [];

  changeTag(String tag) {
    if (hiddenTags.contains(tag)) {
      hiddenTags.remove(tag);
      updateVertex();
    } else {
      hiddenTags.add(tag);
    }
  }

  changeEdge(String edge) {
    if (hiddenEdges.contains(edge)) {
      hiddenEdges.remove(edge);
    } else {
      hiddenEdges.add(edge);
    }
  }

  /// 之所以要另外更新节点，是因为节点隐藏时，无法触发节点对应的 compute 方法
  /// 在 compute 方法中，无法添加隐藏的节点
  updateVertex() {
    graphComponent?.graph.vertexes.forEach((v) {
      var isHidden = hiddenTags.contains(v.tag);
      v.tags?.forEach((tag) {
        isHidden |= hiddenTags.contains(tag);
      });
      if (!isHidden) {
        addCpn(v.cpn!);
      }
    });
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    var isHidden = false;
    v.tags?.forEach((tag) {
      isHidden |= hiddenTags.contains(tag);
    });
    if (isHidden) {
      removeCpn(v.cpn);
      for (var e in v.neighborEdges) {
        removeCpn(e.cpn);
      }
    }
    for (var e in graph.edges) {
      if (e.start.cpn != null &&
          world?.contains(e.start.cpn!) == true &&
          e.end!.cpn != null &&
          world?.contains(e.end!.cpn!) == true &&
          !hiddenEdges.contains(e.edgeName)) {
        addCpn(e.cpn);
      } else {
        removeCpn(e.cpn);
      }
    }
  }

  void removeCpn(Component? c) {
    if (c != null && world?.contains(c) == true) {
      world?.remove(c);
    }
  }

  void addCpn(Component? c) {
    if (c != null && world?.contains(c) != true) {
      world?.add(c);
    }
  }
}
