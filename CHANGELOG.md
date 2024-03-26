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
