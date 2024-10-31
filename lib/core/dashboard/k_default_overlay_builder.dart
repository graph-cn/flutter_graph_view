import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

extension WidgetExt on Widget {
  _expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  Widget _padding(EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  Widget _handleWrapper({
    double width = 185,
    AlignmentGeometry alignment = Alignment.centerLeft,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 3),
  }) {
    return SizedBox(
      width: width,
      child: _padding(padding)._align(alignment: alignment),
    );
  }

  Widget _align({AlignmentGeometry? alignment}) {
    alignment ??= Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: this,
    );
  }
}

kCoulombReserseOverlayBuilder({
  String? kTitle = '节点互斥系数',
  String? sameTagsFactorTitle = '同类聚散',
  String? sameNeighborsFactorTitle = '同邻居聚散',
  Vector2? kRange,
  Vector2? sameTagsFactorRange,
  Vector2? sameNeighborsFactor,
}) {
  return (CoulombReverseDecorator crd) {
    kRange ??= Vector2(crd.k * 0.1, crd.k * 10);
    sameTagsFactorRange ??=
        Vector2(crd.sameTagsFactor * 0.1, crd.sameTagsFactor * 3);
    sameNeighborsFactor ??= Vector2(1, 30);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(kTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: crd.k,
                onChanged: (v) {
                  crd.k = v;
                  setState(() {});
                },
                min: kRange!.x,
                max: kRange!.y,
              );
            }),
          ],
        ),
        Row(
          children: [
            Text(sameTagsFactorTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: crd.sameTagsFactor,
                onChanged: (v) {
                  crd.sameTagsFactor = v;
                  setState(() {});
                },
                min: sameTagsFactorRange!.x,
                max: sameTagsFactorRange!.y,
              );
            }),
          ],
        ),
        Row(
          children: [
            Text(sameNeighborsFactorTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: crd.sameSrcAndDstFactor ?? 1,
                onChanged: (v) {
                  crd.sameSrcAndDstFactor = v;
                  setState(() {});
                },
                min: sameNeighborsFactor!.x,
                max: sameNeighborsFactor!.y,
              );
            }),
          ],
        ),
      ],
    );
  };
}

kHookeOverlayBuilder({
  String? lengthTitle = '上下游距离',
  String? kTitle = '上下游变化系数',
  String? sameTagsFactorTitle = '上下游同类聚散',
  Vector2? lengthRange,
  Vector2? kRange,
  Vector2? sameTagsFactorRange,
}) {
  lengthRange ??= Vector2(0, 200);
  kRange ??= Vector2(0.001, 0.01);
  sameTagsFactorRange ??= Vector2(0, 2);
  return (HookeDecorator hd) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(lengthTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: hd.length,
                onChanged: (v) {
                  hd.length = v;
                  setState(() {});
                },
                min: lengthRange!.x,
                max: lengthRange.y,
              );
            }),
          ],
        ),
        Row(
          children: [
            Text(kTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: hd.k,
                onChanged: (v) {
                  hd.k = min(v, kRange!.y);
                  hd.k = max(hd.k, kRange.x);
                  setState(() {});
                },
                min: kRange!.x,
                max: kRange.y,
              );
            }),
          ],
        ),
        Row(
          children: [
            Text(sameTagsFactorTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: hd.sameTagsFactor,
                onChanged: (v) {
                  hd.sameTagsFactor = v;
                  setState(() {});
                },
                min: sameTagsFactorRange!.x,
                max: sameTagsFactorRange.y,
              );
            }),
          ],
        ),
      ],
    );
  };
}

kHookeBorderOverlayBuilder({
  String? kTitle = '边界约束强弱',
  String? borderFactorRangeTitle = '边界大小',
  String? alwaysInScreenTitle = '视窗居中',
  Vector2? kRange,
  Vector2? kBorderFactorRange,
}) {
  kRange ??= Vector2(0.001, 0.5);
  kBorderFactorRange ??= Vector2(-0.5, 1);
  return (HookeBorderDecorator hbd) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(kTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: hbd.k,
                onChanged: (v) {
                  hbd.k = v;
                  setState(() {});
                },
                min: kRange!.x,
                max: kRange.y,
              );
            }),
          ],
        ),
        Row(
          children: [
            Text(borderFactorRangeTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Slider(
                value: hbd.borderFactor,
                onChanged: (v) {
                  hbd.borderFactor = v;
                  setState(() {});
                },
                min: kBorderFactorRange!.x,
                max: kBorderFactorRange.y,
              );
            }),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(alwaysInScreenTitle!)._expanded(),
            StatefulBuilder(builder: (context, setState) {
              return Checkbox(
                value: hbd.alwaysInScreen,
                onChanged: (v) {
                  hbd.alwaysInScreen = v!;
                  setState(() {});
                },
              );
            })._handleWrapper(
              padding: const EdgeInsets.only(left: 10),
            ),
          ],
        ),
      ],
    );
  };
}

kPauseOverlayBuilder() {
  return (PauseDecorator pd) {
    return StatefulBuilder(builder: (context, setState) {
      return IconButton(
        onPressed: () {
          pd.pause = !pd.pause;
          setState(() {});
        },
        icon: Icon(pd.pause ? Icons.play_arrow : Icons.pause),
      );
    });
  };
}

kGraphRouteOverlayBuilder() {
  return (GraphRouteDecorator grd) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListenableBuilder(
          listenable: grd.backwordQueue,
          builder: (context, child) {
            return IconButton(
              onPressed: grd.backwordQueue.value.isNotEmpty
                  ? () => grd.backword(hideVertexPanel: true)
                  : null,
              icon: const Icon(Icons.chevron_left),
            );
          },
        ),
        ListenableBuilder(
          listenable: grd.forwardQueue,
          builder: (context, child) {
            return IconButton(
              onPressed: grd.forwardQueue.value.isNotEmpty ? grd.forward : null,
              icon: const Icon(Icons.chevron_right),
            );
          },
        ),
      ],
    );
  };
}

typedef LegendBuilder = Widget Function(LegendDecorator)?;
LegendBuilder? kLegendOverlayBuilder() {
  return (LegendDecorator ld) {
    legendBuilder(String tag, Function(String) onTap, Widget icon,
        List<String> allLegend) {
      return StatefulBuilder(builder: (context, setState) {
        return InkWell(
          onTap: () {
            onTap(tag);
            setState(() {});
          },
          child: Opacity(
            opacity: allLegend.contains(tag) ? 0.3 : 1,
            child: SizedBox(
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 9),
                  Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 17,
                      fontFamily: 'ALIBABAPUHUITI',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }

    var graph = ld.graphComponent?.graph;
    if (graph == null) return const SizedBox();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...graph.allTags.map((tag) {
          return legendBuilder(
            tag,
            ld.changeTag,
            ColoredBox(
              color: () {
                var i = graph.allTags.indexOf(tag);
                var graphStyle = ld.graphComponent!.options.graphStyle;
                return graphStyle.colorByTag(tag, graph.allTags) ??
                    (i < graphStyle.tagColorByIndex.length
                        ? graphStyle.tagColorByIndex[i]
                        : graphStyle.defaultColor()[0]);
              }(),
              child: const SizedBox(
                width: 30,
                height: 18,
              ),
            ),
            ld.hiddenTags,
          );
        }),
        ...graph.allEdgeNames.map((edge) {
          return legendBuilder(
            edge,
            ld.changeEdge,
            const Icon(Icons.commit),
            ld.hiddenEdges,
            // ColoredBox(
            //   color: () {
            //     var i = graph.allEdgeNames.indexOf(edge);
            //     var graphStyle = ld.graphComponent!.options.graphStyle;
            //     return graphStyle.colorByEdge(edge, graph.allEdges) ??
            //         (i < graphStyle.edgeColorByIndex.length
            //             ? graphStyle.edgeColorByIndex[i]
            //             : graphStyle.defaultColor()[0]);
            //   }(),
            //   child: const SizedBox(
            //     width: 30,
            //     height: 18,
            //   ),
            // ),
          );
        }),
      ],
    );
  };
}
