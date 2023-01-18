<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

# Flutter Graph View
Widgets for beautiful graphic data structures, such as force-oriented diagrams.

![image](https://user-images.githubusercontent.com/15630211/213280967-443460e8-6ccd-4707-8bf9-8ba970a1f27d.png)

## Features

TODO: 
- [x] Data converter: convert business data into graphic view data.
- [ ] Algorithm: calculate vertex layout.
  - [ ] Force directed algorithm.
  - [x] Random algorithm (In example folder).
- [ ] Data panel embedding.
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
    vertexes.add({'id': 'node$i', 'tag': 'tag${r.nextInt(9)}'});
  }
  var edges = <Map>{};

  for (var i = 0; i < 100; i++) {
    edges.add({
      'srcId': 'node${(i % 10) + 60}',
      'dstId': 'node${i % 3 + 1}',
      'edgeName': 'edge${r.nextInt(3)}',
      'ranking': r.nextInt(DateTime.now().millisecond),
    });
  }

  var data = {
    'vertexes': vertexes,
    'edges': edges,
  };

  runApp(MaterialApp(
    home: FlutterGraphWidget(
      data: data,
      algorithm: ForceDirected(),
      convertor: MapConvertor(),
    ),
  ));
}

```

## Licence

flutter_graph_view is under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
