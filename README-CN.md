
<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

# Flutter Graph View
致力于图数据的可视化组件

![demo](https://foruda.gitee.com/images/1674684822685415888/5033481e_1043207.png)

## Features

TODO: 
- [x] 数据转换器：用于将业务数据转换成组件可以接收的数据格式
- [x] 节点定位：用于将节点合理排布在界面上
  - [x] 随机定位法 (example 中已给出样例).
  - [x] 力导向图法，雏形已实现
    - [x] 节点碰撞检测 
- [x] 提供数据面板的嵌入
- [ ] 提供样式配置
- [ ] 提供更多交互能力

## Getting started

```sh
flutter pub add flutter_graph_view
```

## Usage

```dart
// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

void main() {
  var vertexes = <Map>{};
  var r = Random();
  for (var i = 0; i < 200; i++) {
    vertexes.add(
      {
        'id': 'node$i',
        'tag': 'tag${r.nextInt(9)}',
      },
    );
  }
  var edges = <Map>{};

  for (var i = 0; i < 200; i++) {
    edges.add({
      'srcId': 'node${i % 4}',
      'dstId': 'node$i',
      'edgeName': 'edge${r.nextInt(3)}',
      'ranking': r.nextInt(DateTime.now().millisecond),
    });
  }

  for (var i = 0; i < 20; i++) {
    edges.add({
      'srcId': 'node${r.nextInt(vertexes.length)}',
      'dstId': 'node${r.nextInt(vertexes.length)}',
      'edgeName': 'edge${r.nextInt(3)}',
      'ranking': r.nextInt(DateTime.now().millisecond),
    });
  }

  var data = {
    'vertexes': vertexes,
    'edges': edges,
  };

  runApp(MaterialApp(
    home: Scaffold(
      body: FlutterGraphWidget(
        data: data,
        algorithm: ForceDirected(),
        convertor: MapConvertor(),
        options: Options()
          ..edgePanelBuilder = edgePanelBuilder
          ..vertexPanelBuilder = vertexPanelBuilder
          ..edgeShape = EdgeLineShape() // default is EdgeLineShape.
          ..vertexShape = VertexCircleShape(), // default is VertexCircleShape.
      ),
    ),
  ));
}

Widget edgePanelBuilder(Edge edge) {
  var c = (edge.start.cpn!.position + edge.end!.cpn!.position) / 2;
  return Stack(
    children: [
      Positioned(
        left: c.x + 5,
        top: c.y,
        child: SizedBox(
          width: 150,
          child: ColoredBox(
            color: Colors.white,
            child: ListTile(
              title: Text('${edge.edgeName} @${edge.ranking}'),
            ),
          ),
        ),
      )
    ],
  );
}

Widget vertexPanelBuilder(hoverVertex) {
  return Stack(
    children: [
      Positioned(
        left: hoverVertex.cpn!.position.x + hoverVertex.radius + 5,
        top: hoverVertex.cpn!.position.y - 20,
        child: SizedBox(
          width: 120,
          child: ColoredBox(
            color: Colors.white,
            child: ListTile(
              title: Text(
                'Id: ${hoverVertex.id}',
              ),
              subtitle: Text(
                  'Tag: ${hoverVertex.data['tag']}\nDegree: ${hoverVertex.degree}'),
            ),
          ),
        ),
      )
    ],
  );
}

```

## Licence

flutter_graph_view 遵循 [Apache 2.0 协议](https://www.apache.org/licenses/LICENSE-2.0).
