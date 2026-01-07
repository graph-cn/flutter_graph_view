// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/dampened_force_motion_decorator.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelization_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ForceDirectedParallelDemo extends StatelessWidget {
  ForceDirectedParallelDemo({super.key}){
    _decChoice = parallelMotion;
  }

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();


  var seriesMotion = [
    CoulombDecorator(k: 10),
    HookeDecorator(k: 0.003, length: 120),
    ForceDecorator(),
    ForceMotionDecorator(),
  ];

  var seriesDamped = [
    CoulombDecorator(k: 10),
    HookeDecorator(k: 0.003, length: 120),
    ForceDecorator(),
    DampenedForceMotionDecorator(damping: 0.75, coolingFactor: 0.99),
  ];

  var parallelMotion = [
    ParallelizationDecorator(pDecorators: [
      CoulombDecorator(k: 10),
      HookeDecorator(k: 0.003, length: 120),
    ]),
    ForceDecorator(),
    //
    ForceMotionDecorator(),
  ];

  var parallelDamped = [
    ParallelizationDecorator(pDecorators: [
      CoulombDecorator(k: 10),
      HookeDecorator(k: 0.003, length: 120),
    ]),
    ForceDecorator(),
    DampenedForceMotionDecorator(damping: 0.75, coolingFactor: 0.99),
  ];

  late List<GraphAlgorithm> _decChoice;

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};
    var r = Random();
    for (var i = 0; i < 2000; i++) {
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

    for (var i = 0; i < 2000; i++) {
      edges.add({
        'srcId': 'node${i % 4}',
        'dstId': 'node$i',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': r.nextInt(DateTime.now().millisecond),
      });
    }

    for (var i = 0; i < 200; i++) {
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
    return StatefulBuilder(
        builder: (context, setState) => Stack(
              children: [
                FlutterGraphWidget(
                  key: navigatorKey,
                  data: data,
                  algorithm: RandomOrPersistenceAlgorithm()
                    ..decorators = _decChoice,
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
                    ..vertexShape =
                        VertexCircleShape(), // default is VertexCircleShape.
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Wrap(spacing: 8,
                      children: [
                        SegmentedButton<List<GraphAlgorithm>>(
                          segments:  [
                            ButtonSegment(value: parallelMotion, label: const Text('Parallel Normal')),
                            ButtonSegment(value: parallelDamped, label: const Text('Parallel Damped')),
                            ButtonSegment(value: seriesMotion, label: const Text('Sequential Normal')),
                            ButtonSegment(value: seriesDamped, label: const Text('Sequential Damped')),
                          ],
                          selected: {_decChoice},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _decChoice = newSelection.first;
                            });
                          },
                        )
                      ]
                  )
                ),
              ],
            ));
  }

  Widget edgePanelBuilder(Edge edge) {
    var c = edge.g!.options!.localToGlobal(edge.position);

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
