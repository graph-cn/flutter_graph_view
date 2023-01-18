
<!-- 
  Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.

  This source code is licensed under Apache 2.0 License.
 -->

# Flutter Graph View
致力于图数据的可视化组件

## Features

TODO: 
- [ ] 数据转换器：用于将业务数据转换成组件可以接收的数据格式
- [ ] 节点定位：用于将节点合理排布在界面上
  - [x] 随机定位法 (example 中已给出样例).
  - [x] 力导向图法，雏形已实现
    - [ ] 节点碰撞检测 
- [ ] 提供数据面板的嵌入
- [ ] 提供样式配置
- [ ] 提供更多交互能力

## Getting started

```sh
flutter pub add flutter_graph_view
```

## Usage

```dart
// Copyright (c) 20// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

void main() {
  var vertexes = <Map>{};
  var r = Random();
  for (var i = 0; i < 200; i++) {
    vertexes.add({'id': 'node$i', 'tag': 'tag${r.nextInt(9)}'});
  }
  var edges = <Map>{};

  for (var i = 0; i < 100; i++) {
    edges.add({
      'srcId': 'node${(i % 10) + 60}',
      'dstId': 'node${i % 3 + 1}',
      'edgeName': 'edge${r.nextInt(3)}',
      'ranking': r.nextInt(DateTime.now().millisecond),
    });
  }

  var data = {
    'vertexes': vertexes,
    'edges': edges,
  };

  runApp(MaterialApp(
    home: FlutterGraphWidget(
      data: data,
      // algorithm: RandomAlgorithm(),
    ),
  ));
}

```

## Licence

flutter_graph_view 遵循 [Apache 2.0 协议](https://www.apache.org/licenses/LICENSE-2.0).
