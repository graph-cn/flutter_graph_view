// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Vertex<I> {
  late I id;
  late String tag;
  List<String>? tags;
  late List<Color> colors = [
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
    Color.fromRGBO(
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      Random().nextInt(160) + 80,
      1,
    ),
  ];
  late Vector2 position;
  late dynamic data;

  late double radius = 10;

  Vertex();
}
