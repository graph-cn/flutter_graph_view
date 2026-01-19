// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/dampened_force_motion_decorator.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelizable_decorator.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelization_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ForceDirectedParallelDemo extends StatelessWidget {

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  var _coulomb = CoulombDecorator(k: 10);
  var barnsHut = BarnesHutDecorator(k: 10, theta: 0.4, softening: 0, logCalculationsSkipped: true);
  late GraphAlgorithm _repulsion = barnsHut;

  var hooke = HookeDecorator(k: 0.003, length: 120);
  late GraphAlgorithm _attraction = hooke;

  static const _damping = 0.95;
  static const _coolingFactor = 0.998;
  static const _logMaxMoveThisCycle = true;
  static const _logTimeToStability = true;

  var dampedMotion = DampenedForceMotionDecorator(
    damping: _damping,
    coolingFactor: _coolingFactor,
    logMaxMoveThisCycle: _logMaxMoveThisCycle,
    logTimeToStability: _logTimeToStability,
  );
  var normalMotion = ForceMotionDecorator();
  late GraphAlgorithm _forcesMotion = normalMotion;

  bool _parallel = true;

  int _vertexCount = 1000;


  List<GraphAlgorithm> get _decChoice => [
    PauseDecorator(),
    if (_parallel)
      ParallelizationDecorator(
          logIsolateMessages: false,
          logCycleDuration: true,
          pDecorators: [
            _repulsion as ParallelizableDecorator,
            _attraction as ParallelizableDecorator,
          ]
        ),
    if (!_parallel) _repulsion,
    if (!_parallel) _attraction,
    ForceDecorator(),
    _forcesMotion,
  ];


  @override
  Widget build(BuildContext context) {



    return StatefulBuilder(
        builder: (context, setState) {
          var vertexes = <Map>{};
          var r = Random();
          for (var i = 0; i < _vertexCount / 2; i++) {
            vertexes.add(
              {
                'id': 'node$i',
                'tag': 'tag${r.nextInt(9)}',
                'tags': [
                  'tag${r.nextInt(9)}',
                  if (r.nextBool()) 'tag${r.nextInt(4)}',
                  if (r.nextBool()) 'tag${r.nextInt(8)}'
                ],
                'solid': false,
              },
            );
          }
          var edges = <Map>{};

          for (var i = 0; i < _vertexCount / 2; i++) {
            edges.add({
              'srcId': 'node${i % 4}',
              'dstId': 'node$i',
              'edgeName': 'edge${r.nextInt(3)}',
              'ranking': r.nextInt(DateTime.now().millisecond),
              'solid': false,
            });
          }

          for (var i = 0; i < 50; i++) {
            edges.add({
              'srcId': 'node1',
              'dstId': 'node2',
              'edgeName': 'edge${r.nextInt(3)}',
              'ranking': r.nextInt(DateTime.now().millisecond),
              'solid': false,
            });
          }
          /// end of demo data 1

          for (var i = _vertexCount / 2; i < _vertexCount; i++) {
            vertexes.add(
              {
                'id': 'node$i',
                'tag': 'tag${r.nextInt(9)}',
                'tags': [
                  'tag${r.nextInt(9)}',
                  if (r.nextBool()) 'tag${r.nextInt(4)}',
                  if (r.nextBool()) 'tag${r.nextInt(8)}'
                ],
                'solid': false,
              },
            );
          }

          for (var i = _vertexCount / 2; i < _vertexCount; i++) {
            for (var j = 0; j < r.nextInt(10); j++) {
              edges.add(
                  {
                    'srcId': 'node$i',
                    'dstId': 'node${_vertexCount / 2 + r.nextInt((_vertexCount / 2).toInt())}',
                    'edgeName': 'edge${r.nextInt(3)}',
                    'ranking': r.nextInt(DateTime.now().millisecond),
                    'solid': false,
                  }
              );
            }
          }
          var data = {
            'vertexes': vertexes,
            'edges': edges,
          };
          return Stack(
              children: [
                FlutterGraphWidget(
                  key: navigatorKey,
                  data: _vertexCount == 0 ? data : data,
                  algorithm: RandomOrPersistenceAlgorithm()
                    ..decorators = _decChoice,
                  convertor: MapConvertor(),
                  options: Options()
                    ..enableHit = false
                    ..scaleRange = Vector2(0.0005, 5.0)
                    ..onVertexTapUp = ((vertex, event) {
                      // new data render to graph
                      return data;
                    })
                    ..perBatchTotal = (double.maxFinite.toInt())
                    ..panelDelay = const Duration(milliseconds: 500)
                    ..graphStyle = (GraphStyle()
                      ..hoverOpacity = 0.5
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
                    ..edgeShape = EdgeLineShapeVariableOpacity (
                      normalOpacity: 0.3,
                      hoverOpacityMultiplier: 0.1,
                      decorators: [
                        // ZoomAwareEdgePaintDecorator(),
                        // SafeArrowEdgeDecorator()
                        // SolidArrowEdgeDecorator(),
                      ],
                    ) // default is EdgeLineShape.
                    ..vertexShape =
                        VertexCircleShape(), // default is VertexCircleShape.
                ),
                Positioned(
                  top: 20,
                  left: 20,
                  child: Wrap(spacing: 8,
                      children: [
                        SegmentedButton<bool>(
                          segments:  [
                            ButtonSegment(value: false, label: const Text('Series')),
                            ButtonSegment(value: true, label: const Text('Parallel')),
                          ],
                          selected: {_parallel},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _parallel = newSelection.first;
                            });
                          },
                        ),
                        SegmentedButton<GraphAlgorithm>(
                          segments:  [
                            ButtonSegment(value: _coulomb, label: const Text('Coulomb (Slow)')),
                            ButtonSegment(enabled: _parallel, value: barnsHut, label: const Text('Barns Hut (Fast)')),
                          ],
                          selected: {_repulsion},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              _repulsion = newSelection.first;
                            });
                          },
                        ),
                        SegmentedButton<GraphAlgorithm>(
                          segments:  [
                            ButtonSegment(value: normalMotion, label: const Text('Normal')),
                            ButtonSegment(value: dampedMotion, label: const Text('Damped')),
                          ],
                          selected: {_forcesMotion},
                          onSelectionChanged: (newSelection) {
                            setState(() {
                              // if (newSelection.first == dampedMotion) {
                              //   dampedMotion = DampenedForceMotionDecorator(
                              //     damping: _damping,
                              //     coolingFactor: _coolingFactor,
                              //     logMaxMoveThisCycle: _logMaxMoveThisCycle,
                              //     logTimeToStability: _logTimeToStability,
                              //   );
                              //   _forcesMotion = dampedMotion;
                              // } else{
                                _forcesMotion = newSelection.first;
                              // }
                            });
                          },
                        ),
                        DropdownMenu<int>(
                          initialSelection: _vertexCount,

                          onSelected: (value) {
                            setState(() {
                              _vertexCount = value!;
                            });
                          },
                          dropdownMenuEntries: const [
                            DropdownMenuEntry(value: 50, label: '50'),
                            DropdownMenuEntry(value: 100, label: '100'),
                            DropdownMenuEntry(value: 250, label: '250'),
                            DropdownMenuEntry(value: 500, label: '500'),
                            DropdownMenuEntry(value: 750, label: '750'),
                            DropdownMenuEntry(value: 1000, label: '1,000'),
                            DropdownMenuEntry(value: 2000, label: '2,000'),
                            DropdownMenuEntry(value: 3000, label: '3,000'),
                            DropdownMenuEntry(value: 5000, label: '5,000'),
                            DropdownMenuEntry(value: 7500, label: '7,500'),
                            DropdownMenuEntry(value: 10000, label: '10,000'),
                          ],
                        )

                      ]
                  )
                ),
              ],
            );
        });
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
