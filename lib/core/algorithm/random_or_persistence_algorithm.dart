// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

class RandomOrPersistenceAlgorithm extends RandomAlgorithm {
  Map<dynamic, Vector2?> positionStorage = {};

  RandomOrPersistenceAlgorithm({super.decorators});

  @override
  void onLoad(Vertex v) {
    super.onLoad(v);
    Vector2? cachedPosition = positionStorage[v.id];
    if (cachedPosition != null) {
      v.position = cachedPosition;
    }
    positionStorage[v.id] = v.position;
  }

  @override
  void compute(Vertex v, Graph graph) {
    super.compute(v, graph);
    positionStorage[v.id] = v.position;
  }
}
