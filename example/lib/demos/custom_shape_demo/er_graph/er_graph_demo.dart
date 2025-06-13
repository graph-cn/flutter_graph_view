// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:example/demos/custom_shape_demo/er_graph/connect_widget.dart';
import 'package:example/demos/custom_shape_demo/er_graph/er_graph_table_component.dart';
import 'package:example/demos/custom_shape_demo/er_graph/nothing_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'data.dart';
import 'er_graph_convertor.dart';
import 'schema_vo.dart';

final List<Connection> connections = [];

class ErGraphDemo extends StatelessWidget {
  const ErGraphDemo({super.key});
  static final decorators1 = [
    // CoulombDecorator(),
    // HookeDecorator(),
    // CoulombReverseDecorator(),
    // HookeBorderDecorator(alwaysInScreen: false),
    // ForceDecorator(),
    // ForceMotionDecorator(),
    // TimeCounterDecorator(),
    GraphRouteDecorator(),
    PauseDecorator(),
    PinDecorator(),
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
    return FlutterGraphWidget(
      data: [tables, constants],
      algorithm: rootAlg,
      // algorithm: ErFlowLayout(),
      convertor: ErGraphConvertor(),
      options: Options()
        ..vertexComponentNew = ErGraphTableComponent.new
        ..useLegend = false
        ..vertexShape = NothingShape()
        ..edgeShape = EdgeLineShape(decorators: [SolidArrowEdgeDecorator()])
        ..textGetter = (data) {
          if (data.data is TableVo) {
            return (data.data as TableVo).name;
          }
          return '';
        }
        // ..vertexShape = PlanNodeShape()
        ..graphStyle = (GraphStyle()
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
        ..backgroundBuilder = ((context) => ColoredBox(
              color: Colors.grey.shade800,
              // child: logo,
            )),
    );
  }
}
