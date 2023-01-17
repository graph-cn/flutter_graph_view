// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter_graph_view/flutter_graph_view.dart';

abstract class DataConvertor<V, E> {
  Vertex convertVertex(V v);

  Edge convertEdge(E e);
}
