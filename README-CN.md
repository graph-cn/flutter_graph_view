
<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

# Flutter Graph View

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flutter_graph_view" >
      <img src="https://img.shields.io/badge/Pub-v2.x-red?style=popout" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/stargazers">
      <img src="https://img.shields.io/github/stars/dudu-ltd/flutter_graph_view" alt="GitHub stars" />
  </a>
  <a href="https://github.com/dudu-ltd/flutter_graph_view/network/members">
      <img src="https://img.shields.io/github/forks/dudu-ltd/flutter_graph_view" alt="GitHub forks" />
  </a>
</p>

致力于图数据的可视化组件

![输入图片说明](https://foruda.gitee.com/images/1712005397846215598/d97f4d7e_1043207.png "屏幕截图")

![输入图片说明](https://foruda.gitee.com/images/1712005408211711810/bc5a6037_1043207.png "屏幕截图")

![输入图片说明](https://foruda.gitee.com/images/1712005417532504522/1d44cdfe_1043207.png "屏幕截图")

## 特性

- [x] 数据转换器：用于将业务数据转换成组件可以接收的数据格式
- [x] 节点定位：用于将节点合理排布在界面上
  - [x] 随机定位法 (example 中已给出样例).
  - [x] 力导向图法，雏形已实现
  - [x] 支持定位算法装饰器
    - [x] 提供呼吸效果的自定义装饰器（可选特性）
    - [x] 为相关连节点提供遵循胡克定律的装饰器
    - [x] 为所有节点提供由中心向外的胡克定律的装饰器
    - [x] 为子图根节点提供互斥的的库伦定律装饰器
    - [x] 为所有节点提供边缘缓冲碰撞的胡克定律装饰器
    - [x] 在图中追加一个计数器装饰器，用于将节点受力转换成运动
- [x] 提供数据面板的嵌入
- [x] 提供样式配置
- [ ] 提供更多交互能力

## 如何开始

```sh
flutter pub add flutter_graph_view
```

## 用法

```dart
// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

class DecoratorDemo extends StatelessWidget {
  const DecoratorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    var vertexes = <Map>{};
    var r = Random();
    for (var i = 0; i < 150; i++) {
      vertexes.add(
        {
          'id': 'node$i',
          'tag': 'tag${r.nextInt(9)}',
          'tags': [
            'tag${r.nextInt(9)}',
            if (r.nextBool()) 'tag${r.nextInt(4)}',
            if (r.nextBool()) 'tag${r.nextInt(8)}'
          ],
        },
      );
    }
    var edges = <Map>{};

    for (var i = 0; i < 150; i++) {
      edges.add({
        'srcId': 'node${i % 8 + 8}',
        'dstId': 'node$i',
        'edgeName': 'edge${r.nextInt(3)}',
        'ranking': DateTime.now().millisecond,
      });
    }
    // for (var i = 0; i < 20; i++) {
    //   edges.add({
    //     'srcId': 'node${i % 8}',
    //     'dstId': 'node${r.nextInt(150)}',
    //     'edgeName': 'edge${r.nextInt(3)}',
    //     'ranking': DateTime.now().millisecond,
    //   });
    // }

    var data = {
      'vertexes': vertexes,
      'edges': edges,
    };
    return FlutterGraphWidget(
      data: data,
      algorithm: RandomAlgorithm(
        decorators: [
          CoulombDecorator(),
          // HookeBorderDecorator(),
          HookeDecorator(),
          CoulombCenterDecorator(),
          HookeCenterDecorator(),
          ForceDecorator(),
          ForceMotionDecorator(),
          TimeCounterDecorator(),
        ],
      ),
      convertor: MapConvertor(),
      options: Options()
        ..enableHit = false
        ..panelDelay = const Duration(milliseconds: 500)
        ..graphStyle = (GraphStyle()
          // tagColor is prior to tagColorByIndex. use vertex.tags to get color
          ..tagColor = {'tag8': Colors.orangeAccent.shade200}
          ..tagColorByIndex = [
            Colors.red.shade200,
            Colors.orange.shade200,
            Colors.yellow.shade200,
            Colors.green.shade200,
            Colors.blue.shade200,
            Colors.blueAccent.shade200,
            Colors.purple.shade200,
            Colors.pink.shade200,
            Colors.blueGrey.shade200,
            Colors.deepOrange.shade200,
          ])
        ..edgePanelBuilder = edgePanelBuilder
        ..vertexPanelBuilder = vertexPanelBuilder
        ..edgeShape = EdgeLineShape() // default is EdgeLineShape.
        ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
    );
  }

  Widget edgePanelBuilder(Edge edge, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(edge.position);

    return Stack(
      children: [
        Positioned(
          left: c.x + 5,
          top: c.y,
          child: SizedBox(
            width: 200,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                    '${edge.edgeName} @${edge.ranking}\nDelay controlled by \noptions.panelDelay\ndefault to 300ms'),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget vertexPanelBuilder(hoverVertex, Viewfinder viewfinder) {
    var c = viewfinder.localToGlobal(hoverVertex.cpn!.position);
    return Stack(
      children: [
        Positioned(
          left: c.x + hoverVertex.radius + 5,
          top: c.y - 20,
          child: SizedBox(
            width: 120,
            child: ColoredBox(
              color: Colors.grey.shade900.withAlpha(200),
              child: ListTile(
                title: Text(
                  'Id: ${hoverVertex.id}',
                ),
                subtitle: Text(
                    'Tag: ${hoverVertex.data['tag']}\nDegree: ${hoverVertex.degree} ${hoverVertex.prevVertex?.id}'),
              ),
            ),
          ),
        )
      ],
    );
  }
}

```

## Licence

flutter_graph_view 遵循 [Apache 2.0 协议](https://www.apache.org/licenses/LICENSE-2.0).
