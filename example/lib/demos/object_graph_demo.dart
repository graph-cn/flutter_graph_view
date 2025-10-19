// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ObjectGraphDemo extends StatelessWidget {
  const ObjectGraphDemo({super.key});

  /// Your can use different decorators to get different effects.
  // ignore: unused_local_variable
  static final decorators2 = [
    CounterDecorator(),
    GraphRouteDecorator(),
    LegendDecorator(), // if use this decorator, you should set options.useLegend = false
    PauseDecorator(),
    PinDecorator(),
    CoulombReverseDecorator(
      sameTagsFactor: 0.8,
      sameSrcAndDstFactor: 10,
      handleOverlay: kCoulombReserseOverlayBuilder(),
    ),
    // HookeCenterDecorator(),
    HookeDecorator(
      length: 20,
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
    decorators: decorators2,
  );

  @override
  Widget build(BuildContext context) {
    return FlutterGraphWidget(
      data: data,
      algorithm: rootAlg,
      convertor: MapConvertor(),
      options: Options()
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
        ..edgeShape = EdgeLineShape(
          decorators: [
            SolidArrowEdgeDecorator(),
          ],
        ) // default is EdgeLineShape.
        ..vertexShape = VertexCircleShape(
          decorators: [
            VertexImgDecorator(),
          ],
        ), // default is VertexCircleShape.
    );
  }

  Widget edgePanelBuilder(Edge edge) {
    return Stack(
      children: [
        Positioned(
          left: edge.g!.options!.pointer.x + 1,
          top: edge.g!.options!.pointer.y + 1,
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
    return Stack(
      children: [
        Positioned(
          left: hoverVertex.g!.options!.pointer.x + 1,
          top: hoverVertex.g!.options!.pointer.y + 1,
          child: SizedBox(
            width: 120,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                  'Id: ${hoverVertex.id}',
                ),
                subtitle: Text(
                    'Tag: ${hoverVertex.data['tag']}\nDegree: ${hoverVertex.degree} ${hoverVertex.prevVertex?.id}'),
              ),
            ),
          ),
        )
      ],
    );
  }
}

var data = {
  'vertexes': [
    {
      'id': 'widget',
      'tag': 'Widget',
      'data': {'Widget'},
    },
    {
      'id': 'graph',
      'tag': 'Graph',
      'data': {'Graph'},
    },
    {
      'id': 'options',
      'tag': 'Options',
      'data': {'Options'},
    },
    {
      'id': 'convertor',
      'tag': 'MapConvertor',
      'data': {'MapConvertor'},
    },
    {
      'id': 'algorithm',
      'tag': 'GraphAlgorithm',
      'tags': ['GraphAlgorithm', 'RandomOrPersistenceAlgorithm'],
      'data': {},
    },
    {
      'id': 'counterDecorator',
      'tag': 'CounterDecorator',
      'tags': ['GraphAlgorithm', 'CounterDecorator'],
      'data': {},
    },
    {
      'id': 'graphRouteDecorator',
      'tag': 'GraphRouteDecorator',
      'tags': ['GraphAlgorithm', 'GraphRouteDecorator'],
      'data': {},
    },
    {
      'id': 'legendDecorator',
      'tag': 'LegendDecorator',
      'tags': ['GraphAlgorithm', 'LegendDecorator'],
      'data': {},
    },
    {
      'id': 'pauseDecorator',
      'tag': 'PauseDecorator',
      'tags': ['GraphAlgorithm', 'PauseDecorator'],
      'data': {},
    },
    {
      'id': 'pinDecorator',
      'tag': 'PinDecorator',
      'tags': ['GraphAlgorithm', 'PinDecorator'],
      'data': {},
    },
    {
      'id': 'coulombReverseDecorator',
      'tag': 'CoulombReverseDecorator',
      'tags': ['GraphAlgorithm', 'CoulombReverseDecorator'],
      'data': {},
    },
    {
      'id': 'hookeDecorator',
      'tag': 'HookeDecorator',
      'tags': ['GraphAlgorithm', 'HookeDecorator'],
      'data': {},
    },
    {
      'id': 'hookeBorderDecorator',
      'tag': 'HookeBorderDecorator',
      'tags': ['GraphAlgorithm', 'HookeBorderDecorator'],
      'data': {},
    },
    {
      'id': 'forceDecorator',
      'tag': 'ForceDecorator',
      'tags': ['GraphAlgorithm', 'ForceDecorator'],
      'data': {},
    },
    {
      'id': 'forceMotionDecorator',
      'tag': 'ForceMotionDecorator',
      'tags': ['GraphAlgorithm', 'ForceMotionDecorator'],
      'data': {},
    },
    {
      'id': 'timeCounterDecorator',
      'tag': 'TimeCounterDecorator',
      'tags': ['GraphAlgorithm', 'TimeCounterDecorator'],
      'data': {},
    },
    {
      'id': 'graphComponentCanvas',
      'tag': 'GraphComponentCanvas',
      'tags': ['GraphComponentBuilder', 'GraphComponentCanvas'],
      'data': {},
    },
    // options
    {
      'id': 'graphStyle',
      'tag': 'GraphStyle',
      'tags': ['GraphStyle'],
      'data': {},
    },
    {
      'id': 'edgeLineShape',
      'tag': 'EdgeLineShape',
      'tags': ['EdgeShape', 'EdgeLineShape'],
      'data': {},
    },
    {
      'id': 'solidArrowEdgeDecorator',
      'tag': 'SolidArrowEdgeDecorator',
      'tags': [
        'EdgeDecorator',
        'DefaultEdgeDecorator',
        'SolidArrowEdgeDecorator'
      ],
      'data': {},
    },
    {
      'id': 'vertexCircleShape',
      'tag': 'VertexCircleShape',
      'tags': ['VertexCircleShape', 'VertexCircleShape'],
      'data': {},
    },
    {
      'id': 'vertexImgDecorator',
      'tag': 'VertexImgDecorator',
      'tags': ['VertexDecorator', 'VertexImgDecorator'],
      'data': {},
    },
  ],
  'edges': [
    {
      'srcId': 'graph',
      'dstId': 'widget',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'options',
      'dstId': 'widget',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'convertor',
      'dstId': 'widget',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'algorithm',
      'dstId': 'widget',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'graph',
      'dstId': 'graphComponentCanvas',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'options',
      'dstId': 'graphComponentCanvas',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'convertor',
      'dstId': 'graphComponentCanvas',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'algorithm',
      'dstId': 'graphComponentCanvas',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'options',
      'dstId': 'graph',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'convertor',
      'dstId': 'graph',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'algorithm',
      'dstId': 'graph',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'graph',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'algorithm',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'counterDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'graphRouteDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'legendDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'pauseDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'pinDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'coulombReverseDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'hookeDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'hookeBorderDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'forceDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'forceMotionDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'timeCounterDecorator',
      'dstId': 'algorithm',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'graphStyle',
      'dstId': 'options',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'edgeLineShape',
      'dstId': 'options',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'solidArrowEdgeDecorator',
      'dstId': 'edgeLineShape',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'vertexCircleShape',
      'dstId': 'options',
      'edgeName': 'combind',
      'ranking': 0,
    },
    {
      'srcId': 'vertexImgDecorator',
      'dstId': 'vertexCircleShape',
      'edgeName': 'combind',
      'ranking': 0,
    },
  ],
};
