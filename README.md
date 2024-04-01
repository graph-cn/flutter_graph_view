<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

<h1 align="center"> Flutter Graph View </h1>


<p align="center">
  <a title="Pub" href="https://flame-engine.org" >
      <img src="https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg" />
  </a>
  <a title="Powered by Flame" href="https://pub.dev/packages/flutter_graph_view" >
      <img src="https://img.shields.io/badge/Pub-v1.x-red?style=popout" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/stargazers">
      <img src="https://img.shields.io/github/stars/dudu-ltd/flutter_graph_view" alt="GitHub stars" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/network/members">
      <img src="https://img.shields.io/github/forks/dudu-ltd/flutter_graph_view" alt="GitHub forks" />
  </a>
</p>

Widgets for beautiful graphic data structures, such as force-oriented diagrams.


![image](https://github.com/graph-cn/flutter_graph_view/assets/15630211/0d368544-ad0b-441a-9bbc-a1d0ccdc0fd6)
![image](https://github.com/graph-cn/flutter_graph_view/assets/15630211/dae205f3-6706-44c6-acd6-83a86140a955)

![image](https://github.com/graph-cn/flutter_graph_view/assets/15630211/486b596e-352d-4110-ab2a-ad2381f1ba02)

https://github.com/graph-cn/flutter_graph_view/assets/15630211/a035cd7d-bdac-4ef6-8abf-74594e9d699b

## Features

- [x] Data converter: convert business data into graphic view data.
- [x] Algorithm: calculate vertex layout.
  - [x] Force directed algorithm.
  - [x] Random algorithm (In example folder).
  - [x] Support algorithm decorator.
    - [x] Breathe decorator (optional).
    - [x] Provide decorators that follow Hooke's Law for related nodes
    - [x] Provide a decorator for Hooke's Law from the center outward for all nodes
    - [x] Provide mutually exclusive Coulomb's law decorators for subgraph root nodes
    - [x] Hooke's Law decorator that provides border buffering collisions for all nodes
    - [x] Add a counter decorator in the figure to convert node forces into motion

- [x] Data panel embedding.
- [x] Style configuration.
- [ ] More graphical interactions.

## Getting started

```sh
flutter pub add flutter_graph_view
```

## Usage

```dart
// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class DecoratorDemo extends StatelessWidget {
  const DecoratorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};
    var r = Random();
    for (var i = 0; i < 150; i++) {
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

    for (var i = 0; i < 150; i++) {
      edges.add({
        'srcId': 'node${i % 8 + 8}',
        'dstId': 'node$i',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': DateTime.now().millisecond,
      });
    }
    // for (var i = 0; i < 20; i++) {
    //   edges.add({
    //     'srcId': 'node${i % 8}',
    //     'dstId': 'node${r.nextInt(150)}',
    //     'edgeName': 'edge${r.nextInt(3)}',
    //     'ranking': DateTime.now().millisecond,
    //   });
    // }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };
    return FlutterGraphWidget(
      data: data,
      algorithm: RandomAlgorithm(
        decorators: [
          CoulombDecorator(),
          // HookeBorderDecorator(),
          HookeDecorator(),
          CoulombCenterDecorator(),
          HookeCenterDecorator(),
          ForceDecorator(),
          ForceMotionDecorator(),
          TimeCounterDecorator(),
        ],
      ),
      convertor: MapConvertor(),
      options: Options()
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
        ..useLegend = true // default true
        ..edgePanelBuilder = edgePanelBuilder
        ..vertexPanelBuilder = vertexPanelBuilder
        ..edgeShape = EdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
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
}

```

## Licence

flutter_graph_view is under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
