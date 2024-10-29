// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/material.dart';

import 'demos/custom_shape_demo/execution_plan/execution_plan_demo.dart';
import 'demos/persistence_demo.dart';
import 'demos/vertex_font_style_demo.dart';
import 'demos/decorator_demo.dart';
import 'demos/force_directed_demo.dart';
import 'demos/random_algorithm_demo.dart';
import 'demos/circle_layout_demo.dart';
import 'demos/self_loop_demo.dart';
import 'package:url_launcher/url_launcher.dart';

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
    'PersistenceDemo',
    'ForceDirected',
    'ExecutionPlan',
    'CircleLayout',
    'RandomLayout',
    "SelfLoop",
    "VertexFontStyleDemo",
  ];
  final List<Widget> tabs = <Widget>[
    const DecoratorDemo(),
    const PersistenceDemo(),
    ForceDirectedDemo(),
    ExecutionPlanDemo(),
    CircleLayoutDemo(),
    RandomAlgorithmDemo(),
    const SelfLoopDemo(),
    const VertexFontStyleDemo(),
  ];

  @override
  void initState() {
    super.initState();
    mainTabController =
        TabController(initialIndex: 0, length: tabs.length, vsync: this);
  }

  Uri repo = Uri.parse('https://github.com/graph-cn/flutter_graph_view');

  List buttons = [
    {
      'label': 'Repo',
      'url': 'https://github.com/graph-cn/flutter_graph_view',
      'icon': Icons.link,
    },
    {
      'label': 'Demos',
      'url':
          'https://github.com/graph-cn/flutter_graph_view/tree/main/example/lib/demos',
      'icon': Icons.list,
    }
  ];

  _launchUrl(String url) {
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: buttons.map((button) {
                  return ElevatedButton.icon(
                    icon: Icon(button['icon']),
                    label: Text(button['label']),
                    onPressed: () => _launchUrl(button['url']),
                  );
                }).toList()),
            Expanded(
                child: TabBarView(
              controller: mainTabController,
              children: tabs,
            ))
          ],
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
