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
export 'core/options/shape/vertex/vertex_decorator.dart';
export 'core/options/shape/edge_shape.dart';
export 'core/options/shape/edge/edge_decorator.dart';
export 'core/options/text/vertex_text_renderer.dart';

/// interfaces' default impl
export 'core/algorithm/random_algorithm.dart';
export 'core/algorithm/random_or_persistence_algorithm.dart';
export 'core/algorithm/force_directed.dart';
export 'core/algorithm/circle_layout.dart';

/// decorators
export 'core/algorithm/decorator/breathe_decorator.dart';
export 'core/algorithm/decorator/force_decorator.dart';
export 'core/algorithm/decorator/pin_center_decorator.dart';
export 'core/algorithm/decorator/force_motion_decorator.dart';
export 'core/algorithm/decorator/hooke_decorator.dart';
export 'core/algorithm/decorator/hooke_border_decorator.dart';
export 'core/algorithm/decorator/hooke_center_decorator.dart';
export 'core/algorithm/decorator/coulomb_decorator.dart';
export 'core/algorithm/decorator/coulomb_reverse_decorator.dart';
export 'core/algorithm/decorator/coulomb_center_decorator.dart';
export 'core/algorithm/decorator/coulomb_border_decorator.dart';
export 'core/algorithm/decorator/time_counter_decorator.dart';
export 'core/algorithm/decorator/persistence_decorator.dart';
export 'core/algorithm/decorator/pin_decorator.dart';
export 'core/algorithm/decorator/pause_decorator.dart';
export 'core/algorithm/decorator/graph_route_decorator.dart';
export 'core/algorithm/decorator/legend_decorator.dart';

export 'core/options/shape/vertex/vertex_circle_shape.dart';
export 'core/options/shape/edge/edge_line_shape.dart';
export 'core/options/text/vertex_text_renderer_impl.dart';

/// default overlay builders
export 'core/dashboard/k_default_overlay_builder.dart';

export 'core/options/style/graph_style.dart';

export 'typedef/components_new.dart';

/// third party
export 'package:flame/flame.dart';
export 'package:flame/camera.dart';
export 'package:flame/components.dart';
