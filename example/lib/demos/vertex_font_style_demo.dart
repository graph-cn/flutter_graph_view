// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class VertexFontStyleDemo extends StatelessWidget {
  const VertexFontStyleDemo({super.key});

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};
    var r = Random();
    for (var i = 0; i < 50; i++) {
      vertexes.add(
        {
          'id': 'node$i',
          'tag': 'tag${r.nextInt(9)}',
          'tags': [
            'tag${r.nextInt(9)}',
            if (r.nextBool()) 'tag${r.nextInt(4)}',
            if (r.nextBool()) 'tag${r.nextInt(8)}'
          ],
        },
      );
    }
    var edges = <Map>{};

    for (var i = 0; i < 50; i++) {
      edges.add({
        'srcId': 'node${i % 8}',
        'dstId': 'node$i',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': DateTime.now().millisecond,
      });
    }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };

    return FlutterGraphWidget(
      data: data,
      algorithm: RandomAlgorithm(),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..graphStyle = (GraphStyle()
          ..vertexTextStyleGetter = (vertex, shape) {
            var opacity = shape?.isWeaken(vertex) == true
                ? (vertex.cpn?.options?.graphStyle.hoverOpacity ?? 1)
                : 1.0;
            return TextStyle(color: Colors.white.withOpacity(opacity));
          })
        ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
    );
  }
}
