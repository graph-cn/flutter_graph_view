import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

typedef VertexComponentNew = VertexComponent Function(
  Vertex vertex,
  Graph graph,
  BuildContext context,
  GraphAlgorithm algorithm, {
  Options? options,
  GraphComponent? graphComponent,
});
