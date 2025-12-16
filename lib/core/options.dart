// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/gestures.dart'
    show PointerHoverEvent, PointerScrollEvent, PointerSignalEvent;
import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

/// @en: The builder of the vertex panel, triggered when the mouse hovers.
///
/// @zh: 顶点数据面板的构建器，鼠标悬停到对应节点时触发。
typedef VertexPanelBuilder = Widget Function(
  Vertex hoverVertex,
);

/// @en: The builder of the edge data panel, triggered when the mouse hovers.
///
/// @zh: 边数据面板的构建器，鼠标悬停到对应节点时触发。
typedef EdgePanelBuilder = Widget Function(
  Edge hoverEdge,
);

/// @en: use for create background widget.
///
/// @zh: 用于创建背景
typedef BackgroundBuilder = Widget Function(BuildContext context);

/// @en: The getter of the vertex text style.
///
/// @zh: 顶点文字样式获取器
typedef VertexTextStyleGetter = TextStyle Function(
  Vertex vertex,
  VertexShape? shape,
);

/// @en: The getter of the edge text style.
///
/// @zh: 边文字样式获取器
typedef EdgeTextStyleGetter = TextStyle Function(
  Edge vertex,
  EdgeShape? shape,
);

typedef GraphComponentBuilder = Widget Function({
  Key? key,
  required dynamic data,
  required DataConvertor convertor,
  required BuildContext context,
  required GraphAlgorithm algorithm,
  required Options options,
  required Graph graph,
});

typedef OnScaleStart = void Function(ScaleStartDetails);
typedef OnScaleUpdate = void Function(ScaleUpdateDetails);
typedef OnPointerSignal = void Function(PointerSignalEvent);
typedef OnPointerUp = void Function(PointerUpEvent);
typedef OnPointerDown = void Function(PointerDownEvent);
typedef OnPointerHover = void Function(PointerHoverEvent);

/// The core api for Graph Options.
///
/// 图配置项
class Options {
  GraphComponentBuilder graphComponentBuilder = GraphComponentCanvas.new;

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

  /// if enable hit.
  ///
  /// 是否开启碰撞检测
  bool enableHit = true;

  /// @en: event callback when tap down on vertex.
  ///
  /// @zh: 点下顶点时的回调
  dynamic Function(Vertex vertex, dynamic)? onVertexTapDown;

  /// @en: event callback when tap up on vertex.
  ///
  /// @zh: 抬起顶点时的回调
  dynamic Function(Vertex vertex, dynamic)? onVertexTapUp;

  /// @en: event callback when tap cancel on vertex.
  ///
  /// @zh: 取消顶点时的回调
  dynamic Function(Vertex vertex, dynamic)? onVertexTapCancel;

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

  /// @en: the text getter of vertex.
  ///
  /// @zh: 顶点文字获取器
  String Function(Edge) edgeTextGetter = (Edge edge) => '${edge.ranking}';

  /// @en: the url getter of vertex image.
  ///
  /// @zh: 顶点图片获取器
  String? Function(Vertex) imgUrlGetter = (Vertex vertex) => null;

  /// @en: the delay of overlay disappear.
  ///
  /// @zh: overlay消失的延迟
  Duration? panelDelay;

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
  // VertexComponentNew vertexComponentNew = VertexComponent.new;

  /// @en: control the game pause through external means.
  /// <br>Suitable for creating multiple flutter_graph_widget
  /// <br>and keeping alive without causing the game engine to consume too much computation
  ///
  /// @zh: 从外部决定游戏是否暂停
  /// <br>适用于创建了多个 flutter_graph_widget，
  /// <br>并且 keepAlive 的情况下，又不想让游戏引擎占用过高计算量
  ValueNotifier<bool> pause = ValueNotifier(false);

  /// @en: Due to the large amount of data, layout calculations can easily get stuck in the UI,
  /// <br>so data is calculated in batches to update section positions
  /// <br> Default: Update the positions of 100 vertexes in a single update
  ///
  /// @zh: 由于在数据量大的情况下，布局计算容易卡住 UI，
  /// <br> 因此将数据进行分批计算，从而更新节位置
  /// <br> 默认：单次更新 100个节点的位置
  int perBatchTotal = 100;

  /// @en: Calculate the current batch of layout in batches
  ///
  /// @zh: 分批计算布局的当前批次
  int batchIndex = 0;

  /// @en
  /// @zh: 鼠标滚轮，滚动次数转换成缩放比例的系数
  /// `scale.value = scrollDelta.dy.sign * zoomPerScrollUnit`
  double zoomPerScrollUnit = -0.05;

  /// @en: The drag range of the touchpad is used to distinguish whether it triggers a node click event or a pure drag event
  ///
  /// @zh: 触摸版的拖动范围，用于区分是触发节点单击事件，还是纯拖动事件
  final Vector2 panDelta = Vector2.zero();

  late Graph graph;

  void run() {
    if (graph.vertexes.isEmpty) return;
    var g = currantBatchRange();
    var vertexs = graph.vertexes.sublist(g[0], g[1]);
    for (var vertex in vertexs) {
      graph.algorithm?.compute(vertex, graph);
    }
    batchIndex++;
  }

  /// onPointerHover
  OnPointerHover? _onPointerHover;
  OnPointerHover get onPointerHover =>
      _onPointerHover ??
      (PointerHoverEvent details) {
        pointer.x = details.localPosition.dx;
        pointer.y = details.localPosition.dy;
      };
  set onPointerHover(OnPointerHover? v) => _onPointerHover = v;

  /// onPointerUp
  OnPointerUp? _onPointerUp;
  OnPointerUp get onPointerUp =>
      _onPointerUp ??
      (PointerUpEvent e) {
        if (graph.hoverVertex != null &&
            panDelta.length < graph.hoverVertex!.radius) {
          onVertexTapUp?.call(graph.hoverVertex!, null);
        }
        vertexShape.onPointerUp(e);
      };
  set onPointerUp(OnPointerUp? v) => _onPointerUp = v;

  OnPointerDown? _onPointerDown;
  OnPointerDown get onPointerDown =>
      _onPointerDown ??
      (PointerDownEvent e) {
        vertexShape.onPointerDown(e);
      };
  set onPointerDown(OnPointerDown? v) => _onPointerDown = v;

  /// onPointerSignal
  OnPointerSignal? _onPointerSignal;
  OnPointerSignal get onPointerSignal =>
      _onPointerSignal ??
      (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          var zoomDelta = pointerSignal.scrollDelta.dy.sign * zoomPerScrollUnit;
          if (scale.value + zoomDelta > 0) {
            var oz = scale.value;
            scale.value += zoomDelta;
            var nz = scale.value;
            keepCenter(oz, nz, size.value, pointerSignal.localPosition, offset);
          }
        }
      };
  set onPointerSignal(OnPointerSignal? v) => _onPointerSignal = v;

  /// onScaleStart
  OnScaleStart? _onScaleStart;
  OnScaleStart get onScaleStart =>
      _onScaleStart ??
      (d) {
        scaleVal = scale.value;
        if (graph.hoverVertex == null) hoverable = false;
        panDelta.x = 0;
        panDelta.y = 0;
      };
  set onScaleStart(OnScaleStart? v) => _onScaleStart = v;

  /// onScaleUpdate
  OnScaleUpdate? _onScaleUpdate;
  OnScaleUpdate get onScaleUpdate =>
      _onScaleUpdate ??
      (ScaleUpdateDetails details) {
        if (details.pointerCount == 2 && details.scale != 1.0) {
          var oz = scale.value;
          scale.value = scaleVal * details.scale;
          var nz = scale.value;
          keepCenter(oz, nz, size.value, pointer.toOffset(), offset);
        } else {
          var delta = details.focalPointDelta;
          pointer.x += delta.dx;
          pointer.y += delta.dy;
          var ifBreak = vertexShape.onDrag(delta.toVector2());
          if (ifBreak) return;
          if (graph.hoverVertex == null) {
            offset.value += delta;
          } else {
            var dragDetail = delta.toVector2() / scale.value;
            panDelta.add(dragDetail);
            graph.algorithm?.onDrag(graph.hoverVertex, delta.toVector2());
          }
        }
      };
  set onScaleUpdate(OnScaleUpdate? v) => _onScaleUpdate = v;

  // ---------------------------------------------------------------------------

  bool hoverable = true;

  /// @en: The position of the mouse in the initial state.
  ///
  /// @zh: 起始状态下，鼠标的位置
  final Vector2 pointer = Vector2.all((2 << 16) + 0.0);

  /// @en: Real time zoom factor of canvas.
  ///
  /// @zh: 画布的实时缩放倍数
  ValueNotifier<double> scale = ValueNotifier(1);

  /// @en: Canvas zoom factor during the most recent touchpad zoom.
  ///
  /// @zh: 画布在最近一次触摸板缩放时，缩放倍数
  double scaleVal = 1;

  /// @en: The offset of the canvas relative to viewport.
  ///
  /// @zh: 画布相对于视窗的偏移量
  ValueNotifier<Offset> offset = ValueNotifier(Offset.zero);

  /// @en: The visual status of the panel when a vertex is clicked
  ///
  /// @zh: 节点被点击时，面板的可视状态
  ValueNotifier<bool> vertexTapUpPanelVisible = ValueNotifier(false);

  ///
  ValueNotifier<bool> verticalControllerVisible = ValueNotifier(false);
  ValueNotifier<bool> horizontalPanelVisible = ValueNotifier(true);

  void hideVerticalPanel() {
    verticalControllerVisible.value = false;
  }

  void hideVertexTapUpPanel() {
    vertexTapUpPanelVisible.value = false;
  }

  void hideHorizontalOverlay() {
    horizontalPanelVisible.value = false;
  }

  void showVertexTapUpPanel() {
    vertexTapUpPanelVisible.value = true;
    verticalControllerVisible.value = false;
  }

  void showVerticalPanel() {
    vertexTapUpPanelVisible.value = false;
    verticalControllerVisible.value = true;
  }

  ValueNotifier<Size> size = ValueNotifier(Size.zero);

  /// @en: Convert the coordinates within the canvas to the coordinates in viewport.
  ///
  /// @zh: 将画布内的坐标，转换成在视窗内的坐标
  Vector2 localToGlobal(Vector2 position) {
    var scaleOffset = size.value * (1 - scale.value) / 2;
    var scaleVector = Vector2(scaleOffset.width, scaleOffset.height);
    return (position * scale.value + scaleVector + offset.value.toVector2());
  }

  /// @en: Convert coordinates from viewport to coordinates within the canvas.
  ///
  /// @zh: 将视窗中的坐标，转换成画布内的坐标
  Vector2 globalToLocal(Vector2 global, {double? scale}) {
    var scaleVal = scale ?? this.scale.value;
    var scaleOffset = size.value * (1 - scaleVal) / 2;
    var scaleVector = Vector2(scaleOffset.width, scaleOffset.height);
    return (global - scaleVector - offset.value.toVector2()) / scaleVal;
  }

  /// @en: When the canvas undergoes a zoom operation,
  /// <br> make the canvas zoom in and out with the mouse focus as the center.
  ///
  /// @zh: 当画布产生缩放操作时，使画布以鼠标焦点为中心，进行缩放
  void keepCenter(
    double oldScale,
    double newScale,
    Size size,
    Offset localPosition,
    ValueNotifier<Offset> offset,
  ) {
    var oldLocal = globalToLocal(localPosition.toVector2(), scale: oldScale);
    var newLocal = globalToLocal(localPosition.toVector2(), scale: newScale);
    var delta = newLocal - oldLocal;
    var global = delta * newScale;
    offset.value += global.toOffset();
  }

  /// @en: Merge the graph data.
  ///
  /// @zh: 合并图数据
  void mergeGraph(dynamic graphData, {bool manual = true}) {
    if (manual) graph.algorithm?.beforeMerge(graphData);
    graph.convertor?.convertGraph(graphData, graph: graph);
  }

  /// @en: Refresh graph data.
  ///
  /// @zh: 刷新图数据
  void refreshData(dynamic data) {
    graph.clear();
    graph.data = data;
    graph.convertor?.convertGraph(data, graph: graph);
    var sortedList = graph.vertexes.toSet().toList()
      ..sort((key1, key2) => key1.degree - key2.degree > 0 ? -1 : 1);
    sortedList
        .where((e) => !graph.vertexes.contains(e))
        .forEach(graph.vertexes.add);
    setDefaultVertexColor();
    graph.algorithm?.onGraphLoad(graph);
    graphStyle.graphColor(graph);
  }

  /// @en: Set default colors for different labels.
  ///
  /// @zh: 为不同标签设置默认颜色
  void setDefaultVertexColor() {
    var tagColorByIndex = graphStyle.tagColorByIndex;
    var needCount = graph.allTags.length - tagColorByIndex.length;
    for (var i = tagColorByIndex.length; i < needCount; i++) {
      tagColorByIndex.add(graphStyle.defaultColor()[0]);
    }
  }

  /// @en: The coordinates formed by the viewport on the canvas
  ///
  /// @zh: 视窗在画布中形成的坐标
  Rect get visibleWorldRect {
    return Rect.fromPoints(
      globalToLocal(Vector2.zero()).toOffset(),
      globalToLocal(Vector2(size.value.width, size.value.height)).toOffset(),
    );
  }

  /// @en: Retrieve the index range of the current batch in the vertex collection
  ///
  /// @zh: 获取当前批在节点集合中的下标范围
  List<int> currantBatchRange() {
    var batchLen = graph.vertexes.length ~/ perBatchTotal + 1;
    batchIndex = (batchIndex % batchLen).toInt();
    var start = batchIndex * perBatchTotal;
    var end = (batchIndex + 1) * perBatchTotal < graph.vertexes.length
        ? (batchIndex + 1) * perBatchTotal
        : graph.vertexes.length;
    return [start, end];
  }
}
