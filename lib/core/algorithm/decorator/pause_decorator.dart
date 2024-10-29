// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class PauseDecorator extends GraphAlgorithm {
  bool pause;
  Widget Function(PauseDecorator)? handleOverlay;

  @override
  Widget Function()? get horizontalOverlay => () => handleOverlay!(this);

  PauseDecorator({
    this.pause = false,
    this.handleOverlay,
    List<GraphAlgorithm>? decorators,
  }) : super(decorators: decorators) {
    handleOverlay = handleOverlay ?? kPauseOverlayBuilder();
  }

  @override
  bool needContinue(Vertex v) {
    return !pause;
  }
}
