// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class CounterDecorator extends GraphAlgorithm {
  final ValueNotifier<int> v = ValueNotifier(0);
  final ValueNotifier<int> e = ValueNotifier(0);
  final ValueNotifier val = ValueNotifier(0);
  Widget Function(CounterDecorator)? handleOverlay;

  @override
  Widget Function()? get horizontalOverlay => () => handleOverlay!(this);

  CounterDecorator({
    this.handleOverlay,
    super.decorators,
  }) {
    handleOverlay = handleOverlay ?? kCounterOverlayBuilder();
    update() => val.value = DateTime.now().millisecondsSinceEpoch;
    v.addListener(update);
    e.addListener(update);
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    this.v.value = graph.vertexes.length;
    e.value = graph.edges.length;
  }

  Widget Function(CounterDecorator) kCounterOverlayBuilder() {
    return (CounterDecorator counter) {
      return ListenableBuilder(
        listenable: counter.val,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child:
                Text('Vertex: ${counter.v.value}   Edge: ${counter.e.value}'),
          );
        },
      );
    };
  }
}
