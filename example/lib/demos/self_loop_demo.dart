// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class SelfLoopDemo extends StatelessWidget {
  const SelfLoopDemo({super.key});

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};

    vertexes.addAll([
      {
        'id': 'node',
        'tag': 'tag',
        'tags': ['tag'],
      },
      {
        'id': 'node2',
        'tag': 'tag3',
        'tags': ['tag', 'tag2'],
      }
    ]);
    var edges = <Map>{};

    for (var i = 0; i < 300; i++) {
      edges.add({
        'srcId': 'node',
        'dstId': 'node${i.isEven ? '2' : ''}',
        'edgeName': 'edge$i',
        'ranking': i,
      });
    }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };
    return FlutterGraphWidget(
      data: data,
      algorithm: ForceDirected(),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..graphStyle = (GraphStyle()
          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
          ..tagColor = {'tag': Colors.orangeAccent.shade200})
        ..edgeShape = EdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
    );
  }
}
