// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

library flutter_graph_view;

/// data models
export './model/graph.dart';
export './model/vertex.dart';
export './model//edge.dart';

/// widgets
export 'flutter_graph_widget.dart';
export './widgets/graph_component.dart';
export './widgets/vertex_component.dart';
export './widgets/edge_component.dart';

/// data convertors
export 'package:flutter_graph_view/core/data_convertor.dart';
export 'package:flutter_graph_view/core/convertor/map_convertor.dart';

/// core interfaces
export 'core/options.dart';
export 'core/graph_algorithm.dart';
export 'core/options/shape/vertex_shape.dart';
export 'core/options/shape/edge_shape.dart';

/// interfaces' default impl
export 'core/algorithm/force_directed.dart';
export 'core/algorithm/breathe_decorator.dart';
export 'core/options/shape/vertex/vertex_circle_shape.dart';
export 'core/options/shape/edge/edge_line_shape.dart';

export 'core/options/style/graph_style.dart';

/// third party
export 'package:flame/flame.dart';
export 'package:flame/camera.dart';
export 'package:flame/components.dart';
