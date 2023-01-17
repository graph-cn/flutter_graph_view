// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'algorithm/random_algorithm.dart';

void main() {
  var vertexes = <Vertex>{};

  for (var i = 0; i < 200; i++) {
    vertexes.add(Vertex());
  }
  var edges = <Edge>{};

  for (var i = 0; i < 10; i++) {
    edges.add(Edge()
      ..start = vertexes.elementAt(Random().nextInt(vertexes.length))
      ..end = vertexes.elementAt(Random().nextInt(vertexes.length)));
  }
  runApp(
    FlutterGraphView(
      vertexes: vertexes,
      edges: edges,
      algorithm: RandomAlgorithm(),
    ),
  );
}
