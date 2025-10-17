// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'execution_plan_convertor.dart';
import 'flow_layout.dart';
import 'plan_node_shape.dart';

// 执行计划可视化面板组件
class ExecutionPlanPanel extends StatelessWidget {
  final dynamic data;
  const ExecutionPlanPanel({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null || data.plan == null || data is! ResultSet) {
      return const SizedBox.shrink();
    }

    return FlutterGraphWidget(
      data: data.plan,
      algorithm: FlowLayout(),
      convertor: ExecutionPlanConvertor(),
      options: Options()
        ..vertexShape = PlanNodeShape()
        ..graphStyle = (GraphStyle()
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
        ..backgroundBuilder = ((context) => ColoredBox(
              color: Colors.grey.shade800,
              // child: logo,
            )),
    );
  }
}
