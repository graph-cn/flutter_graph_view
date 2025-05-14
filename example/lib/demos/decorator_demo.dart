// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class DecoratorDemo extends StatelessWidget {
  const DecoratorDemo({super.key});

  /// Your can use different decorators to get different effects.
  // ignore: unused_local_variable
  static final decorators2 = [
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

  // ignore: unused_local_variable
  static final decorators1 = [
    CoulombDecorator(),
    HookeDecorator(),
    CoulombReverseDecorator(),
    HookeBorderDecorator(alwaysInScreen: false),
    ForceDecorator(),
    ForceMotionDecorator(),
    TimeCounterDecorator(),
  ];

  static final rootAlg = RandomOrPersistenceAlgorithm(
    decorators: decorators2,
  );

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};
    var r = Random();

    for (var i = 0; i < 50; i++) {
      var t = r.nextInt(9);
      vertexes.add(
        {
          'id': 'node$i',
          'tag': 'tag$t',
          'tags': [
            'tag$t',
          ],
          'data': {
            // 'img':
            //     'https://thirdwx.qlogo.cn/mmopen/vi_32/PiajxSqBRaEKcbaToty539YVticyVn8SibszFFmibwjr0X9xgPwRUHCh4tOT4MKaVEMItc8bn7VsZmqKDiaSHCKfF391x0GwVOFjuBNibK37Dg6xribBtYEXP4Jzg/132'
          },
        },
      );
    }
    var edges = <Map>{};

    for (var i = 0; i < 50; i++) {
      if (i % 4 != i) {
        edges.add({
          'srcId': 'node${i % 4}',
          'dstId': 'node$i',
          'edgeName': 'edge${r.nextInt(3)}',
          'ranking': r.nextInt(DateTime.now().millisecond),
        });
      }
    }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };

    return FlutterGraphWidget(
      data: data,
      algorithm: rootAlg,
      convertor: MapConvertor(),
      options: Options()
        ..onVertexTapUp = ((vertex, event) {
          vertex.cpn?.graphComponent?.mergeGraph(genData(vertex.id));
        })
        ..enableHit = false
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
        ..useLegend = false // default true
        ..imgUrlGetter = imgUrlGetter
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

  Widget edgePanelBuilder(Edge edge, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(edge.position);

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

  Widget vertexPanelBuilder(hoverVertex, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(hoverVertex.cpn!.position);
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
                    'Tag: ${hoverVertex.data['tag']}\nDegree: ${hoverVertex.degree} ${hoverVertex.prevVertex?.id}'),
              ),
            ),
          ),
        )
      ],
    );
  }

  genData(srcId) {
    var vertexes = <Map>{};
    var edges = <Map>{};
    var r = Random();
    for (var i = 0; i < 5; i++) {
      var dstId = r.nextInt(30) + 40;
      var newTag = 'tag${r.nextInt(12) + 9}';
      vertexes.add(
        {
          'id': 'node$dstId',
          'tag': newTag,
          'tags': [
            newTag,
            if (r.nextBool()) 'tag${r.nextInt(4)}',
            if (r.nextBool()) 'tag${r.nextInt(8)}'
          ],
        },
      );
      edges.add({
        'srcId': srcId,
        'dstId': 'node$dstId',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': 0,
      });
    }
    return {
      'vertexes': vertexes,
      'edges': edges,
    };
  }

  String? imgUrlGetter(Vertex p1) {
    return p1.data['data']?['img'];
  }
}
