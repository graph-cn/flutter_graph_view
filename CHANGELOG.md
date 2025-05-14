## 1.1.6
- feat: 为 edge 新增 `SolidArrowEdgeDecorator` 实心箭头装饰器
    > support `SolidArrowEdgeDecorator` for edge

## 1.1.5

- feat: Support controlling the game pause or play through the `options.pause`.
    > 支持通过 `options.pause` 控制游戏暂停或播放。
- feat: Support specifying node components through `options.vertexComponentNew`
    > 支持通过 `options.vertexComponentNew` 指定节点组件。

## 1.1.4+1
- fix: the issue of edge overlap when the edgeName is different but same src, dst and edgeId.

## 1.1.4
- feat: add interface to `GraphAlgorithm`: `afterDrag`, `beforeMerge` and etc.
- feat: add `LegendDecorator` to support the legend of the graph, to control the vertex and edge display. And fix the scroll issue of the legend panel.
    - feat: 新增 `LegendDecorator`，支持图的图例，控制节点和边的显示。并修复图例面板的滚动问题。
    example:
    ```dart
    // First add LegendDecorator to your decorators, 
    // then set the legend options.
    options
        ..useLegend = false
    ```
- behavior changed: remove `speed` property from `VertexComponent`.
    > What will be effective is that all the vertex.position will be set to the vertex.cpn.position directly, when decorating the vertex in `GraphAlgorithm` and sub-classes.

- behavior changed: set the radius of vertex to a private variable
- feat: adding `GraphRouteDecorator`, make the data like a brower history.
    - feat: 新增 `GraphRouteDecorator`，使数据像浏览器历史一样，支持前进后退，当有合并行为发生时。

- feat: adding `PauseDecorator`, make the graph stop updating.
    - feat: 新增 `PauseDecorator`，使图的节点停止位置更新。

- feat: adding control panels of decorators.
    example:
    ```dart
      /// 指定装饰器参数的控制面板创建方法
      CoulombReverseDecorator(
        handleOverlay: kCoulombReserseOverlayBuilder(),
      ),
    ```
- feat: enable configuring the force factor between brother vertexs.
    example:
    ```dart
    /// @en: Make the repulsion between similar points smaller
    /// 
    /// @zh: 使相似点之间的排斥力变小
    CoulombReverseDecorator(sameSrcAndDstFactor: 1.1), 
    ```
- fix: the line added later covers the previous point.
- feat: support image vertex.
- feat: using tag similarity as a layout element.
    example:
    ```dart
    /// @en: Make the repulsion between similar tags smaller
    /// 
    /// @zh: 使相似标签之间的排斥力变小
    CoulombReverseDecorator(sameTagsFactor: 0.8), 
    ```

- feat: add `dragged` property to `VertexComponent` to indicate whether the vertex is being dragged.

## 1.1.3+1
- fix: the crash issue when force is not a number [ForceMotionDecorator].

## 1.1.3
- feat: `EdgeLineShape` can append decorators.
    - feat: 使 `EdgeLineShape` 可以追加装饰器。
    ```dart
        Options()
            ..edgeShape = EdgeLineShape(
                decorators: [
                    DefaultEdgeDecorator(),
                ],
            )
    ```

- fix: the edge overlap problem of multiple edge graphs with two identical nodes.
- fix: Edge with the same parameters except for different edge type is misdiagnosed as the same edge.
- fix: correct the position of the two points of the edge.
    - fix: 修正边的两个点的位置。
- fix: the overlap issue of the data panel.

## 1.1.2
- feat: support specifying legends and legend text build.
    
    example:
    ```dart
    Options()
        ..legendBuilder = (color, i) { // default
            return RectangleComponent.fromRect(
                Rect.fromLTWH(40, 50.0 + 30 * i, 30, 18),
                paint: Paint()..color = color,
            );
        }
        ..legendTextBuilder = (tag, i, color, position) { // default
            return TextComponent(
                text: tag,
                position: Vector2(position.x + 40, position.y - 6),
                // position: Vector2(position.x + 40, position.y - 2),
                // textRenderer: TextPaint(
                //   style: TextStyle(
                //     fontSize: 17.0,
                //     color: Colors.white,
                //   ),
                // ),
            );
        }
    ```

## 1.1.1
- fix usage of both Scale and Pan on mobile platforms. ( [#12](https://github.com/graph-cn/flutter_graph_view/pull/12), via: [Mykyta Sadchenko](https://github.com/muknta))
- feat: support zooming through gestures.

## 1.1.0
- feat: add interface to `GraphComponent`: addVertex, addEdge, mergeGraph
- feat: add implementation of PersistenceDecorator to store position of vertex. ([#10](https://github.com/graph-cn/flutter_graph_view/pull/10) [#11](https://github.com/graph-cn/flutter_graph_view/pull/11), via: [jersonal-com](https://github.com/jersonal-com))

### Behavior change:
- interface change: add a graph parameter to `DataConvertor.convertGraph`
    > 接口变更：为 convertGraph 添加一个graph参数


## 1.0.4+2
- fix: prevent the addition of duplicate data.

## 1.0.4+1
- fix: vertex text style `background` not working.

## 1.0.4
- feat: support specifying vertex text style.

## 1.0.3
- feat add a choice to HookeBorderDecorator, to control the border of the graph.
- fix: make CoulombCenterDecorator a usable decorator.

## 1.0.2
- feat: add a decorator for the anti Coulomb force rule.

## 1.0.1
- feat: make opacity configurable for vertex and edge. `options.hoverOpacity`
- perf: adjusting the parameters of the decorators.

## 1.0.0
- feat: add a series of decorators to the GraphAlgorithm.

### Behavior change:
- Changed the parameter of the `GraphAlgorithm` constructor from [decorator] to {decorators}

## 0.3.0
- perf: use `panelDelay` in the options to control the delay time of the display panel.
* fix: hover testing of edges, multiple edges and self loops
* fix: edge overlap, when there are even numbers of edges between two points
* fix: let the self loop follow the scaling law.
* feat: self loop support
* refac: adjusting the file structure of the VertexTextRenderer interface
* fix: graph crash, when there is no panelBuilder.

## 0.2.4+1
- fix: graph crash, when there is no panelBuilder.

## 0.2.4
- feat: synchronously update panel positions, when dragging nodes.

## 0.2.3
- feat: add method: displayName to VertexComponent. Used textGetter.

## 0.2.2+2
- fix: edge panel display issue. Make overlay name unique.
- fix: increase the mouse touch area on the edge.

## 0.2.2+1
- fix: graph crash, when there is no panelBuilder.

## 0.2.2
- fix: [#6](https://github.com/graph-cn/flutter_graph_view/issues/6)
    - change the loading timing of the panel to be at the same time as vertex/edge components loading.
    - change the panel to correspond one-to-one with the components.
- feat: add 'panelDelay' to options to control the delay time hidden in the panel.

## 0.2.1
- feat: add property of `size` to Vertex.

## 0.2.0
- feat: add textGetter to vertex
- feat: add onGraphLoad callback in graph_algorithm
- feat: add CircleLayout for graph
- enhance: set edge color by vertex color

## 0.1.0
- feat: Added option to 'Enable collision detection'(`enableHit`), default to `false`
- feat: Added option to 'scaleRange', default to `[0.05, 5.0]`
- feat: Display vertex title, default to `vertex.id`
- refact: refact the interactive logic of drag and zoom by viewfinder

### Dev change:
- vertexPanelBuilder and edgePanelBuilder access another param: `Viewfinder`
    use `Viewfinder` to convert the position of the component to the global position, such as:
    ```dart
        viewfinder.localToGlobal( cpnPosition );
    ```

## 0.0.2
- feat: enable decorator for vertex.
    - Remove the breath effect. To use the breath effect, please pass in BreatheDecorator() when creating the GraphAlgorithm object, such as:
    ```dart
    FlutterGraphWidget(
        ...
        algorithm: ForceDirected(BreatheDecorator()),
        ...
    )
    ```
    
- feat: adding custom properties to vertex components helps the algorithm create more effects.
<!-- 将对flame的依赖升级到最新版本 -->
- dependency: upgrade flame from 1.6.0 to 1.7.0


## 0.0.1+10
- feat:  support multi line between two vertexes.
- enhance: optimized edge experience. 
  - hover height 1->3
  - edge highlight when component hovered.
      ![image](https://user-images.githubusercontent.com/15630211/217449742-1eb95787-c53a-450d-bff9-08f3ed2b1b8c.png)


## 0.0.1+9
- feat: create random color for tag.
- feat: add legend in graph.

## 0.0.1+8
- feat(convert): cache the edge names and vertex tags in graph.
- feat: support customize background.
- feat(options style): support assigning colors to vertexes through tags (name or index).

## 0.0.1+7
- feat: supported customize vertex ui.
- feat: supported customize edge ui.

## 0.0.1+6
- Data panel embedding. ( For edge )
- Fixed: components overflow game window.
- Fixed: `Options.vertexPanelBuilder` nullable as expected.

## 0.0.1+5
- Keep children vertexes around the parent vertex.
- Data panel embedding.

## 0.0.1+4
- Support zoom in and zoom out.
- Support global drag and vertex drag.
- Support custom reposition collision callbacks.

## 0.0.1+3
- Provide placement scheme of random positions in the circle with collision detection.

## 0.0.1+2
- Integrated game engine to do data display. ( nodes | relationships )
- Provided layout algorithm interface.
- Provided data convertor interface.
