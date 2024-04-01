// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

/// Add a time counter to the graph
///
/// 为图添加一个时间计数器
class TimeCounterDecorator extends GraphAlgorithm {
  TimeCounterDecorator({super.decorators});

  @override
  void onLoad(Vertex v) {
    super.onLoad(v);
    v.cpn?.properties.putIfAbsent('timeCounter', () => 0);
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    v.cpn!.properties['timeCounter'] += 1;
  }
}
