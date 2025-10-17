// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class CircleLayoutDemo extends StatelessWidget {
  CircleLayoutDemo({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
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
        'srcId': 'node${i % 4}',
        'dstId': 'node$i',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': r.nextInt(DateTime.now().millisecond),
      });
    }

    for (var i = 0; i < 50; i++) {
      edges.add({
        'srcId': 'node1',
        'dstId': 'node2',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': r.nextInt(DateTime.now().millisecond),
      });
    }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };
    return FlutterGraphWidget(
      key: navigatorKey,
      data: data,
      algorithm: CircleLayout(),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..onVertexTapUp = ((vertex, event) {
          // new data render to graph
          return data;
        })
        ..panelDelay = const Duration(milliseconds: 500)
        ..graphStyle = (GraphStyle()
          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
          ..tagColor = {'tag8': Colors.orangeAccent.shade200}
          ..tagColorByIndex = [
            Colors.red.shade200,
            Colors.orange.shade200,
            Colors.yellow.shade200,
            Colors.green.shade200,
            Colors.blue.shade200,
            Colors.blueAccent.shade200,
            Colors.purple.shade200,
            Colors.pink.shade200,
            Colors.blueGrey.shade200,
            Colors.deepOrange.shade200,
          ])
        ..edgePanelBuilder = edgePanelBuilder
        ..vertexPanelBuilder = vertexPanelBuilder
        ..edgeShape = EdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
    );
  }

  Widget edgePanelBuilder(Edge edge) {
    var c = (edge.g!.options!.localToGlobal(edge.start.position) +
            edge.g!.options!.localToGlobal(edge.end!.position)) /
        2;

    return Stack(
      children: [
        Positioned(
          left: c.x + 5,
          top: c.y,
          child: SizedBox(
            width: 200,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                    '${edge.edgeName} @${edge.ranking}\nDelay controlled by \noptions.panelDelay\ndefault to 300ms'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget vertexPanelBuilder(Vertex hoverVertex) {
    var c = hoverVertex.g!.options!.localToGlobal(hoverVertex.position);
    return Stack(
      children: [
        Positioned(
          left: c.x + hoverVertex.radius + 5,
          top: c.y - 20,
          child: SizedBox(
            width: 120,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                  'Id: ${hoverVertex.id}',
                ),
                subtitle: Text(
                    'Tag: ${hoverVertex.data['tag']}\nDegree: ${hoverVertex.degree}'),
              ),
            ),
          ),
        )
      ],
    );
  }
}
