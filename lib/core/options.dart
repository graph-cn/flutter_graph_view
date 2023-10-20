// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/camera.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// The core api for Graph Options.
///
/// 图配置项
class Options {
  /// The builder of the vertex panel, triggered when the mouse hovers.
  ///
  /// 顶点数据面板的构建器，鼠标悬停到对应节点时触发。
  Widget Function(Vertex hoverVertex, Viewfinder zoom)? vertexPanelBuilder;

  /// The builder of the edge data panel, triggered when the mouse hovers.
  ///
  /// 边数据面板的构建器，鼠标悬停到对应节点时触发。
  Widget Function(Edge hoverVertex, Viewfinder zoom)? edgePanelBuilder;

  /// set shape strategy for components of vertex.
  ///
  /// 给点设置形状
  VertexShape vertexShape = VertexCircleShape();

  /// set shape strategy for components of edge.
  ///
  /// 给边设置形状
  EdgeShape edgeShape = EdgeLineShape();

  /// use for create background widget.
  ///
  /// 用于创建背景
  Widget Function(BuildContext) backgroundBuilder = (context) => Container(
        color: Colors.black54,
      );

  GraphStyle graphStyle = GraphStyle();

  /// if render legend in canvas.
  ///
  /// 是否展示图例
  bool useLegend = true;

  /// if enable hit.
  ///
  /// 是否开启碰撞检测
  bool enableHit = true;

  /// @en: event callback when tap down on vertex.
  ///
  /// @zh: 点下顶点时的回调
  dynamic Function(Vertex vertex, TapDownEvent)? onVertexTapDown;

  /// @en: event callback when tap up on vertex.
  ///
  /// @zh: 抬起顶点时的回调
  dynamic Function(Vertex vertex, TapUpEvent)? onVertexTapUp;

  /// @en: event callback when tap cancel on vertex.
  ///
  /// @zh: 取消顶点时的回调
  dynamic Function(Vertex vertex, TapCancelEvent)? onVertexTapCancel;
}
