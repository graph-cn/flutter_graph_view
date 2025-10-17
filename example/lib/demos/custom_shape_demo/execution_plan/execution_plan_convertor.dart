// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/painting.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

import 'data.dart';

/// 执行计划到图数据的转换器
class ExecutionPlanConvertor extends DataConvertor<ExecutionPlanNode, Map> {
  @override
  Vertex convertVertex(v, g) {
    Vertex vertex = Vertex();
    vertex.g = g;
    vertex.id = v.id;
    vertex.tag = v.name ?? '';
    vertex.tags = [v.name ?? ''];

    vertexAsGraphComponse(v, g, vertex);
    var node = vertex.data as ExecutionPlanNode;
    // 计算三行文本的宽度，最大宽度为结点的宽度

    var textStyle =
        g.options?.graphStyle.vertexTextStyleGetter?.call(vertex, null);
    var row1 = textPainter(node.nameWithId, textStyle);
    var row2 = textPainter(node.outputVarWithLabel, textStyle);
    var row3 = textPainter(node.inputVarWithLabel, textStyle);
    vertex.size = Size(
      max(max(row1.width, row2.width), row3.width),
      row1.height * 3,
    );

    return vertex;
  }

  TextPainter textPainter(String text, TextStyle? textStyle) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: textStyle ?? const TextStyle(fontSize: 14),
        text: text,
      ),
    )..layout();
  }

  @override
  Edge convertEdge(e, g) {
    Edge result = Edge();
    result.g = g;
    result.ranking = 0;
    result.edgeName = "";

    result.start = g.keyCache[e['srcId']]!;
    result.end = g.keyCache[e['dstId']];

    edgeAsGraphComponse(e, g, result);

    return result;
  }

  @override
  Graph convertGraph(data, {Graph? graph}) {
    var result = graph ?? Graph();
    result.data = data;

    if (data is ExecutionPlan) {
      var vertexDataList = originVertexes(data);
      var edgeDataList = originEdges(data);
      for (var v in vertexDataList) {
        Vertex vertex = convertVertex(v, result);
        result.vertexes.add(vertex);
        v.dependencies?.forEach((element) {
          edgeDataList.add({
            "srcId": element,
            "dstId": v.id,
          });
        });
      }
      for (var e in edgeDataList) {
        Edge edge = convertEdge(e, result);
        result.edges.add(edge);
      }
    }
    return result;
  }

  Iterable originVertexes(dynamic data) => data.nodes ?? [];

  List originEdges(dynamic data) => <Map>[];
}
