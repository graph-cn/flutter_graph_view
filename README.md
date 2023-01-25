<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

# Flutter Graph View
Widgets for beautiful graphic data structures, such as force-oriented diagrams. (Under development.)

![image](https://user-images.githubusercontent.com/15630211/214703510-17ccfe4d-e3f6-49b9-9bc1-6ce84bd825a8.png)

https://user-images.githubusercontent.com/15630211/214360687-93a3683c-0935-46bd-9584-5cb997d518b8.mp4

## Features

TODO: 
- [x] Data converter: convert business data into graphic view data.
- [x] Algorithm: calculate vertex layout.
  - [x] Force directed algorithm.
  - [x] Random algorithm (In example folder).
- [x] Data panel embedding.
- [ ] Style configuration.
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

  for (var i = 0; i < 20; i++) {
    edges.add({
      'srcId': 'node${r.nextInt(vertexes.length)}',
      'dstId': 'node${r.nextInt(vertexes.length)}',
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
        algorithm: ForceDirected(),
        convertor: MapConvertor(),
        options: Options()
          ..edgePanelBuilder = edgePanelBuilder
          ..vertexPanelBuilder = vertexPanelBuilder,
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
        left: hoverVertex.cpn!.position.x + hoverVertex.cpn!.radius + 5,
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
