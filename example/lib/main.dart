// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:example/demos/circle_layout_demo.dart';
import 'package:example/demos/self_loop_demo.dart';
import 'package:flutter/material.dart';

import 'demos/custom_shape_demo/execution_plan/execution_plan_demo.dart';
import 'demos/decorator_demo.dart';
import 'demos/force_directed_demo.dart';
import 'demos/random_algorithm_demo.dart';

void main() {
  runApp(const Showroom());
}

class Showroom extends StatefulWidget {
  const Showroom({super.key});

  @override
  State<Showroom> createState() => _ShowroomState();
}

class _ShowroomState extends State<Showroom>
    with SingleTickerProviderStateMixin {
  late TabController mainTabController;

  final List<String> tabNames = <String>[
    'DecoratorDemo',
    'ForceDirected',
    'ExecutionPlan',
    'CircleLayout',
    'RandomLayout',
    "SelfLoop",
  ];
  final List<Widget> tabs = <Widget>[
    const DecoratorDemo(),
    ForceDirectedDemo(),
    ExecutionPlanDemo(),
    CircleLayoutDemo(),
    RandomAlgorithmDemo(),
    const SelfLoopDemo(),
  ];

  @override
  void initState() {
    super.initState();
    mainTabController =
        TabController(initialIndex: 0, length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: TabBarView(
          controller: mainTabController,
          children: tabs,
        ),
        bottomNavigationBar: TabBar(
          controller: mainTabController,
          tabs: tabNames
              .map((tabName) => Tab(
                    child: Tooltip(message: tabName, child: Text(tabName)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
