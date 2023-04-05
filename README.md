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
      <img src="https://img.shields.io/badge/Pub-v0.0.1+x-red?style=popout" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/stargazers">
      <img src="https://img.shields.io/github/stars/dudu-ltd/flutter_graph_view" alt="GitHub stars" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/network/members">
      <img src="https://img.shields.io/github/forks/dudu-ltd/flutter_graph_view" alt="GitHub forks" />
  </a>
</p>

Widgets for beautiful graphic data structures, such as force-oriented diagrams.

![image](https://user-images.githubusercontent.com/15630211/216155004-0d6dc826-c589-41cf-bf7c-a51685582c05.png)

![image](https://user-images.githubusercontent.com/15630211/217449742-1eb95787-c53a-450d-bff9-08f3ed2b1b8c.png)

https://user-images.githubusercontent.com/15630211/214360687-93a3683c-0935-46bd-9584-5cb997d518b8.mp4

## Features

- [x] Data converter: convert business data into graphic view data.
- [x] Algorithm: calculate vertex layout.
  - [x] Force directed algorithm.
  - [x] Random algorithm (In example folder).
  - [x] Support algorithm decorator.
    - [x] Breathe decorator (optional).
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

void main() {
  var vertexes = <Map>{};
  var r = Random();
  for (var i = 0; i < 200; i++) {
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

  for (var i = 0; i < 200; i++) {
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

  runApp(MaterialApp(
    home: Scaffold(
      body: FlutterGraphWidget(
        data: data,
        algorithm: ForceDirected(BreatheDecorator()),
        convertor: MapConvertor(),
        options: Options()
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
      ),
    ),
  ));
}

Widget edgePanelBuilder(Edge edge) {
  var c = (edge.start.cpn!.position + edge.end!.cpn!.position) / 2;
  return Stack(
    children: [
      Positioned(
        left: c.x + 5,
        top: c.y,
        child: SizedBox(
          width: 150,
          child: ColoredBox(
            color: Colors.white,
            child: ListTile(
              title: Text('${edge.edgeName} @${edge.ranking}'),
            ),
          ),
        ),
      )
    ],
  );
}

Widget vertexPanelBuilder(hoverVertex) {
  return Stack(
    children: [
      Positioned(
        left: hoverVertex.cpn!.position.x + hoverVertex.radius + 5,
        top: hoverVertex.cpn!.position.y - 20,
        child: SizedBox(
          width: 120,
          child: ColoredBox(
            color: Colors.white,
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

```

## Licence

flutter_graph_view is under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
