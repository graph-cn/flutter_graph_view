// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'algorithm/random_algorithm.dart';

void main() {
  var vertexes = <Map>{};
  var r = Random();
  for (var i = 0; i < 200; i++) {
    vertexes.add({'id': 'node$i', 'tag': 'tag${r.nextInt(9)}'});
  }
  var edges = <Map>{};

  for (var i = 0; i < 100; i++) {
    // edges.add({
    //   'srcId': 'node${r.nextInt(vertexes.length)}',
    //   'dstId': 'node${r.nextInt(vertexes.length)}',
    //   'edgeName': 'edge${r.nextInt(3)}',
    //   'ranking': r.nextInt(DateTime.now().millisecond),
    // });
    edges.add({
      'srcId': 'node${(i % 10) + 60}',
      'dstId': 'node${i % 3 + 1}',
      'edgeName': 'edge${r.nextInt(3)}',
      'ranking': r.nextInt(DateTime.now().millisecond),
    });
  }

  var data = {
    'vertexes': vertexes,
    'edges': edges,
  };

  runApp(MaterialApp(
    home: FlutterGraphWidget(
      data: data,
      // algorithm: RandomAlgorithm(),
    ),
  ));
}
