// Copyright (c) 2023- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'package:flutter/widgets.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'data.dart';

/// 执行计划的布局逻辑与流程图类似
class FlowLayout extends GraphAlgorithm {
  double rowGap = 40;
  double colGap = 10;
  double sameParentGap = 10;

  List<int> nodeOrder = [];

  Map<int, ExecutionPlanNode> nodeCache = {};

  List<List<List<int>>> children = [];

  Map<int, Vector2> nodePosition = {};

  FlowLayout({super.decorators});

  /// 基本思路：
  ///
  /// - 当完成图数据加载
  ///   1. 建立结点的缓存，更快通过 id 获取到执行计划数据
  ///   2. 建立节点排序，将遍历方式固化
  ///   3. 通过多维的 id 数组，决定节点在平面中的位置，如：
  ///       ```json
  ///           [
  ///                [[ 6 ], [ 17 ]],
  ///                [[1], [2, 3]],
  ///                [[4, 5], [6], [7]]
  ///           ]
  ///       ```
  ///       以上数据表示：
  ///       1. 节点6、17处在图像中的第一行，并且属于不同的父结点
  ///       2. 节点1 处在图像中的第二行，所属父节点为 6
  ///       3. ...
  ///   4. 通过步骤3形成的粗略位置坐标，搭配节点的尺寸，给定每个节点具体的位置（像素）
  @override
  void onGraphLoad(Graph graph) {
    graph.data as ExecutionPlan;
    fillCache(graph.data);
    fillOrder(graph.data);
    makeUpChildren(graph.data);

    computePosition(graph);
  }

  /// 对初始布局考虑充分的情况下，
  /// 可以通过覆盖[onDrag]方法，并使用空实现，以禁用节点的拖拽效果
  @override
  void onDrag(Vertex hoverVertex, info, Viewfinder viewfinder) {}

  /// 一次性布局完成时，不需要重复刷新图像信息，[compute]同样给上空实现
  @override
  // ignore: must_call_super
  bool? compute(Vertex v, Graph graph) {
    // v.cpn?.game.pauseEngine();
    // if (decorators != null) {
    //   for (var decorator in decorators!) {
    //     decorator.compute(v, graph);
    //   }
    // }
    return true;
  }

  /// 建立结点的缓存，更快通过 id 获取到执行计划数据
  void fillCache(ExecutionPlan plan) {
    plan.nodes?.forEach((node) {
      if (node.id != null) nodeCache.putIfAbsent(node.id!, () => node);
    });
  }

  /// 建立节点排序，将遍历方式固化
  void fillOrder(ExecutionPlan plan) {
    var list = <int>[];
    for (ExecutionPlanNode n in plan.nodes ?? []) {
      if (n.dependencies == null || n.dependencies!.isEmpty) {
        list.add(n.id!);
      }
    }

    children.add([
      ...list.map(
        (e) => [e],
      )
    ]);
    for (int i = 0; i < list.length; i++) {
      int id = list[i];
      plan.nodes?.forEach((node) {
        node.dependencies?.forEach((d) {
          if (id == d && !list.contains(node.id!)) {
            list.add(node.id!);
          }
        });
      });
    }
    nodeOrder.addAll(list);
  }

  void makeUpChildren(ExecutionPlan plan) {
    for (int i = 0; i < children.length; i++) {
      var sameLevelParent = children[i];
      var nextLevel = <List<int>>[];
      for (int j = 0; j < sameLevelParent.length; j++) {
        for (int k = 0;
            j < sameLevelParent.length && k < sameLevelParent[j].length;
            k++) {
          var sameParent = <int>[];
          var parentId = sameLevelParent[j][k];
          plan.nodes?.forEach((n) {
            if (n.dependencies?.contains(parentId) == true &&
                !sameParent.contains(n.id)) {
              sameParent.add(n.id!);
            }
          });
          if (sameParent.isNotEmpty && !nextLevel.deepContains(sameParent)) {
            nextLevel.add(sameParent);
          }
          // if (sameLevelParent.deepContains(sameParent)) {
          //   sameLevelParent
          //       .removeWhere((e) => e.toString() == sameParent.toString());
          // }
        }
      }
      if (nextLevel.isNotEmpty && !children.deepContains(nextLevel)) {
        children.add(nextLevel);
      }
    }
  }

  /// 通过步骤3形成的粗略位置坐标，搭配节点的尺寸，给定每个节点具体的位置（像素）
  void computePosition(Graph graph) {
    List<double> rowMaxWidth = List.filled(children.length, 0);
    double maxWidth = 0;
    for (int i = 0; i < children.length; i++) {
      for (int j = 0; j < children[i].length; j++) {
        for (int k = 0; k < children[i][j].length; k++) {
          rowMaxWidth[i] +=
              graph.keyCache[nodeCache[children[i][j][k]]!.id!]!.size!.width;
        }
        rowMaxWidth[i] += (children[i][j].length - 1) * sameParentGap;
      }
      rowMaxWidth[i] += (children[i].length - 1) * colGap;
      if (rowMaxWidth[i] > maxWidth) {
        maxWidth = rowMaxWidth[i];
      }
    }

    double topOffset = 80;
    for (int i = 0; i < children.length; i++) {
      var child = children[i];
      var last = null;
      double leftOffset = maxWidth / 2;
      double maxHeight = 0;
      leftOffset -=
          (rowMaxWidth[i] - graph.keyCache[child.first.first]!.size!.width) / 2;
      for (int j = 0; j < child.length; j++) {
        for (int k = 0; k < child[j].length; k++) {
          var vtx = graph.keyCache[nodeCache[child[j][k]]!.id!]!;
          // 先赋值，再累加
          if (last != null) {
            leftOffset += (last.size!.width + vtx.size!.width) * 0.5;
          }
          leftOffset += sameParentGap;
          if (vtx.size!.height > maxHeight) {
            maxHeight = vtx.size!.height;
          }
          vtx.position = Vector2(leftOffset + 30, topOffset);
          last = vtx;
        }
        leftOffset += colGap;
      }
      // 高度赋值
      topOffset += maxHeight;
      topOffset += rowGap;
    }
  }

  TextPainter textPainter(String text) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        style: const TextStyle(fontSize: 14),
        text: text,
      ),
    )..layout();
  }
}

/// 拓展集合的 [List.contains] 方法，使之具备深度判断的功能。
extension ListDeepContains on Iterable {
  bool deepContains(Iterable it) {
    bool flag = false;
    if (this is Iterable<Iterable>) {
      forEach((that) {
        var f = true;
        for (var i in it) {
          f &= (that as Iterable).contains(i);
        }
        flag |= f;
      });
    }
    var set = toSet();
    if (!flag) set.add(it);
    return length == set.length;
  }
}
