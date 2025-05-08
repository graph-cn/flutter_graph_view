// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// @en: The builder of the vertex panel, triggered when the mouse hovers.
///
/// @zh: 顶点数据面板的构建器，鼠标悬停到对应节点时触发。
typedef VertexPanelBuilder = Widget Function(
  Vertex hoverVertex,
  Viewfinder zoom,
);

/// @en: The builder of the edge data panel, triggered when the mouse hovers.
///
/// @zh: 边数据面板的构建器，鼠标悬停到对应节点时触发。
typedef EdgePanelBuilder = Widget Function(
  Edge hoverEdge,
  Viewfinder zoom,
);

/// @en: use for create background widget.
///
/// @zh: 用于创建背景
typedef BackgroundBuilder = Widget Function(BuildContext context);

/// @en: The getter of the vertex text style.
///
/// @zh: 顶点文字样式获取器
typedef VertexTextStyleGetter = TextStyle? Function(
  Vertex vertex,
  VertexShape? shape,
);

/// The core api for Graph Options.
///
/// 图配置项
class Options {
  /// The builder of the vertex panel, triggered when the mouse hovers.
  ///
  /// 顶点数据面板的构建器，鼠标悬停到对应节点时触发。
  VertexPanelBuilder? vertexPanelBuilder;

  Widget? vertexTapUpPanel;

  /// The builder of the edge data panel, triggered when the mouse hovers.
  ///
  /// 边数据面板的构建器，鼠标悬停到对应节点时触发。
  EdgePanelBuilder? edgePanelBuilder;

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
  BackgroundBuilder backgroundBuilder = (context) => Container(
        color: Colors.black54,
      );

  GraphStyle graphStyle = GraphStyle();

  /// if render legend in canvas.
  ///
  /// 是否展示图例
  @Deprecated("use LegendDecorator instead. will remove in 1.2.0")
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

  /// @en: the graph scale range. default to `Vector2(0.05, 5)`
  ///
  /// @zh: 图缩放范围
  Vector2 scaleRange = Vector2(0.05, 5.0);

  /// @en: if show text in vertex. default `vertex.id`, if you want to show other text, you can set `textGetter`.
  ///
  /// @zh: 是否展示顶点文字，默认展示顶点id，如果想展示其他文字，可以设置`textGetter`
  bool showText = true;

  /// @en: the text getter of vertex.
  ///
  /// @zh: 顶点文字获取器
  String Function(Vertex) textGetter = (Vertex vertex) => '${vertex.id}';

  /// @en: the url getter of vertex image.
  ///
  /// @zh: 顶点图片获取器
  String? Function(Vertex) imgUrlGetter = (Vertex vertex) => null;

  /// @en: the delay of overlay disappear.
  ///
  /// @zh: overlay消失的延迟
  Duration? panelDelay;

  /// @en: legend component builder
  ///
  /// @zh: 图例组件
  PositionComponent Function(Color color, int i) legendBuilder = (color, i) {
    return RectangleComponent.fromRect(Rect.fromLTWH(40, 50.0 + 30 * i, 30, 18),
        paint: Paint()..color = color);
  };

  /// @en: default legend text builder
  ///
  /// @zh: 默认图例文字构建器
  TextComponent Function(String tag, int i, Color color, Vector2 position)
      legendTextBuilder = (tag, i, color, position) {
    return TextComponent(
      text: tag,
      position: Vector2(position.x + 40, position.y - 6),
    );
  };

  /// @en: the horizontal controller panel height. Default to `50`
  ///
  /// @zh: 水平控制面板的高度。默认为`50`
  double horizontalControllerHeight = 50;

  /// @en: the vertical controller panel width. Default to `340`
  ///
  /// @zh: 垂直控制面板的宽度。默认为`340`
  double verticalControllerWidth = 340;

  /// @en: the vertex tap up panel width. Default to `430`
  ///
  /// @zh: 节点控制面板默认最大宽度，默认值`430`
  double vertexTapUpPanelWidth = 430;

  /// @en: an custom vertex component constructor.
  ///
  /// @zh: 自定义顶点组件构造器
  VertexComponentNew vertexComponentNew = VertexComponent.new;

  /// @en: control the game pause through external means.
  /// <br>Suitable for creating multiple flutter_graph_widget
  /// <br>and keeping alive without causing the game engine to consume too much computation
  ///
  /// @zh: 从外部决定游戏是否暂停
  /// <br>适用于创建了多个 flutter_graph_widget，
  /// <br>并且 keepAlive 的情况下，又不想让游戏引擎占用过高计算量
  ValueNotifier<bool> pause = ValueNotifier(false);
}
