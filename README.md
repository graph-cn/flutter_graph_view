<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Flutter Graph View
An open source project which can display beautiful graph data structure. 

## Features

TODO: 
- [ ] Data converter: convert business data into graphic view data.
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

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'algorithm/random_algorithm.dart';

void main() {
  var vertexes = <Vertex>{};

  for (var i = 0; i < 200; i++) {
    vertexes.add(Vertex());
  }
  var edges = <Edge>{};

  for (var i = 0; i < 10; i++) {
    edges.add(Edge()
      ..start = vertexes.elementAt(Random().nextInt(vertexes.length))
      ..end = vertexes.elementAt(Random().nextInt(vertexes.length)));
  }
  runApp(
    FlutterGraphView(
      vertexes: vertexes,
      edges: edges,
      algorithm: RandomAlgorithm(),
    ),
  );
}

```

## Licence

flutter_graph_view is under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
