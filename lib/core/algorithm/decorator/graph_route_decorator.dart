// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class GraphRouteDecorator extends GraphAlgorithm {
  double step = 0;
  Widget Function(GraphRouteDecorator)? handleOverlay;

  final ValueNotifier<Queue<dynamic>> backwordQueue = ValueNotifier(Queue());
  final ValueNotifier<Queue<dynamic>> forwardQueue = ValueNotifier(Queue());

  dynamic initData;

  @override
  Widget Function()? get horizontalOverlay => () => handleOverlay!(this);

  GraphRouteDecorator({
    this.handleOverlay,
    super.decorators,
  }) {
    handleOverlay = handleOverlay ?? kGraphRouteOverlayBuilder();
  }

  @override
  beforeMerge(dynamic data) {
    backwordQueue.value.add(data);
    forwardQueue.value.clear();
    setState();
    super.beforeMerge(data);
  }

  @override
  beforeLoad(dynamic data) {
    super.beforeLoad(data);
    initData = data;
  }

  void backword({bool hideVertexPanel = false}) {
    if (backwordQueue.value.isEmpty) return;
    var graphData = backwordQueue.value.removeLast();
    forwardQueue.value.add(graphData);
    graph?.refreshData?.call(initData);
    if (hideVertexPanel) hideVertexTapUpOverlay();
    setState();
    for (var element in backwordQueue.value) {
      graph?.mergeGraph?.call(element, manual: false);
    }
  }

  void forward() {
    if (forwardQueue.value.isEmpty) return;
    var graphData = forwardQueue.value.removeLast();
    backwordQueue.value.add(graphData);
    graph?.mergeGraph?.call(graphData, manual: false);
    setState();
  }

  void setState() {
    if ([0, 1].contains(backwordQueue.value.length)) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      backwordQueue.notifyListeners();
    }
    if ([0, 1].contains(forwardQueue.value.length)) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      forwardQueue.notifyListeners();
    }
  }
}
