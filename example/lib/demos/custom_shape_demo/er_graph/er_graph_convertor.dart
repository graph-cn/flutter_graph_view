// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:example/demos/custom_shape_demo/er_graph/schema_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class ErGraphConvertor extends DataConvertor<TableVo, Constants> {
  @override
  Edge convertEdge(Constants e, Graph g) {
    Edge result = Edge();
    result.g = g;
    result.ranking = 0;
    result.edgeName = e.schema;

    result.start = g.keyCache['${e.tableSchema}.${e.tableName}']!;
    result.end =
        g.keyCache['${e.referencedTableSchema}.${e.referencedTableName}'];

    edgeAsGraphComponse(e, g, result);

    return result;
  }

  @override
  Graph convertGraph(data, {Graph? graph}) {
    var result = Graph();
    result.data = data;

    if (data is List<List<dynamic>>) {
      var vertexDataList = data[0];
      var edgeDataList = data[1];
      for (var v in vertexDataList) {
        Vertex vertex = convertVertex(v, result);
        result.vertexes.add(vertex);
      }
      for (var e in edgeDataList) {
        Edge edge = convertEdge(e, result);
        result.edges.add(edge);
      }
    }
    return result;
  }

  @override
  Vertex convertVertex(TableVo v, Graph g) {
    Vertex vertex = Vertex();
    vertex.g = g;
    vertex.id = '${v.db == null ? '' : v.db!.name}.${v.name}';
    vertex.tag = v.name;
    vertex.tags = [v.db?.name ?? ''];

    vertexAsGraphComponse(v, g, vertex);
    var node = vertex.data as TableVo;
    // 计算三行文本的宽度，最大宽度为结点的宽度
    var row1 = textPainter(node.name);
    var row2 = textPainter(node.properties
        .map((e) =>
            '${e.name} ${e.type}${e.length != null ? '(${e.length})' : ''}')
        .join('\n'));
    vertex.size = Size(
      max(row1.width, row2.width) + 14,
      row1.height + row2.height,
    );

    return vertex;
  }

  TextPainter textPainter(String text) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        text: text,
      ),
    )..layout();
  }
}
