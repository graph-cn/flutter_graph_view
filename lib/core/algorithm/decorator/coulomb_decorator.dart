// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter_graph_view/core/algorithm/decorator/parallelizable_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:isolate_manager/isolate_manager.dart';

/// Decorators in which all nodes in the figure form repulsive interactions with
/// each other. The Radius of the node determines the strength of the repulsion.
///
/// 图中所有节点相互间形成排斥的装饰器（库仑力）
class CoulombDecorator extends ForceDecorator implements ParallelizableDecorator {
  double k;

  CoulombDecorator({this.k = 10, super.sameTagsFactor = 1});

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    for (var b in graph.vertexes) {
      if (v != b &&
          v.position != Vector2.zero() &&
          b.position != Vector2.zero()) {
        // F = k * q1 * q2 / r^2
        var delta = v.position - b.position;
        var distance = delta.length;
        var force = k * v.radius * b.radius / max((distance * distance), 1);
        var f = delta * force;
        setForceMap(v, b, f);
      }
    }
  }


  @override
  Map<String, dynamic> serialize({Map<String, dynamic> params = const {}}) {
    return super.serialize(params: {
      "k": k,
      "sameTagsFactor": sameTagsFactor,
    });
  }

  @override
  String get isolateFuncWorkerName => "COULOMB_ISOLATE_FUNC";

  @override
  void Function(dynamic) get isolateAttachFunc => isolateFunc;

  @pragma('vm:entry-point')
  @isolateManagerCustomWorker
  static void isolateFunc(dynamic params) {
    IsolateManagerFunction.customFunction<ComputeRes, Map<String, dynamic>>(
      params,
      onEvent: (controller, jsonInput) {
        final perVertexCalcMap = ComputeRes();

        // extract parameters from json input
        double k = jsonInput["decorator"]["params"]["k"];
        Map<String, Map<String, dynamic>> vertexMap = jsonInput["graph"]["vertexes"];
        List<Map<String, dynamic>> vertexes = vertexMap.values.toList();

        // initialize per vertex map with 0 forces
        for (var v in vertexes) {
          perVertexCalcMap[v["id"]] = Vector2.zero();
        }


        for (int i = 0; i < vertexes.length; i++) {
          for (int j = i+1; j < vertexes.length; j++) {
            final v = vertexes[i];
            final gv = vertexes[j];

            Vector2 vPos = v["position"];
            Vector2 gvPos = gv["position"];
            if (v["id"] !=gv["id"] &&
                vPos != Vector2.zero() &&
                gvPos != Vector2.zero()
            ) {
              // F = k * q1 * q2 / r^2
              final delta = vPos - gvPos;
              final distance = delta.length;
              final vDeg = max(v["radius"]-1, 1.0);
              final vGDeg = max(gv["radius"]-1, 1.0);
              final force = k * vDeg * vGDeg / max((distance * distance), 1);

              perVertexCalcMap[v["id"]] += delta * force;
              perVertexCalcMap[gv["id"]] += -delta * force;

              // possible other calculation ???? It might help with stability by
              // limiting the force scaling to the "other"'s radius/degree.
              // final vDeg = max(v["degree"]-1, 1.0);
              // final vGDeg = max(gv["degree"]-1, 1.0);
              // final force = k / max((distance * distance), 1);
              // perVertexCalcMap[v["id"]] += delta * force * vGDeg;
              // perVertexCalcMap[gv["id"]] += -delta * force * vDeg;
            }
          }
        }
        return perVertexCalcMap;
      },
      autoHandleException: true, // Set to true to let IsolateManager handle basic errors
      autoHandleResult: true,    // Set to true to let IsolateManager handle basic result sending
    );
  }
}
