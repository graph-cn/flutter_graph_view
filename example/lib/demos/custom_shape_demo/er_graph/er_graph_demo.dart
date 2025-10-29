// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:example/demos/custom_shape_demo/er_graph/connect_widget.dart';
import 'package:example/demos/custom_shape_demo/er_graph/er_graph_constants_shape.dart'
    show ErGraphConstantsShape;
import 'package:example/demos/custom_shape_demo/er_graph/er_graph_table_shape.dart'
    show ErGraphTableShape;
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'data.dart';
import 'er_graph_convertor.dart';
import 'schema_vo.dart';

final List<Connection> connections = [];

class ErGraphDemo extends StatelessWidget {
  final Graph graph = Graph();
  ErGraphDemo({super.key});
  static final decorators1 = [
    PinDecorator(),
    CoulombDecorator(),
    // HorizontalHookeDecorator(),
    PauseDecorator(),
    CoulombDecorator(
      // sameTagsFactor: 5,
      k: 50,
    ),
    // HookeCenterDecorator(),
    HookeDecorator(
      length: 200,
      handleOverlay: kHookeOverlayBuilder(),
      degreeFactor: (l, d) => l + d * 10,
    ),
    HookeBorderDecorator(
      handleOverlay: kHookeBorderOverlayBuilder(),
      alwaysInScreen: false,
    ),
    ForceDecorator(),
    ForceMotionDecorator(),
    TimeCounterDecorator(),
  ];

  static final rootAlg = RandomOrPersistenceAlgorithm(
    decorators: decorators1,
  );
  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (contex, setStatet) {
      return Stack(
        children: [
          FlutterGraphWidget(
            data: [tables, constants],
            algorithm: rootAlg,
            // algorithm: ErFlowLayout(),
            convertor: ErGraphConvertor(),
            options: Options()
              ..edgeShape = ErGraphConstantsShape(color: Colors.white)
              ..textGetter = (data) {
                if (data.data is TableVo) {
                  return (data.data as TableVo).name;
                }
                return '';
              }
              ..vertexShape = ErGraphTableShape()
              ..graphStyle = (GraphStyle()
                ..vertexTextStyleGetter = ((v, s) {
                  return const TextStyle(fontSize: 10, color: Colors.white);
                })
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
              ..backgroundBuilder = ((context) => const ColoredBox(
                    color: Colors.transparent,
                    // child: logo,
                  )),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: TextButton(
              onPressed: () => setStatet(() {}),
              child: const Text('Refresh'),
            ),
          ),
        ],
      );
    });
  }
}
