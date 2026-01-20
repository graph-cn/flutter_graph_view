// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelizable_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:isolate_manager/isolate_manager.dart';


/// Construct a decorative device with spring force between connected nodes.
///
/// 在相连节点间构建弹簧力的装饰器。
class HookeDecorator extends ForceDecorator implements ParallelizableDecorator  {
  double length;
  double k;
  double Function(double length, int degree)? degreeFactor;

  @override
  Widget Function()? get verticalOverlay =>
      handleOverlay != null ? () => handleOverlay!(this) : null;

  Widget Function(HookeDecorator)? handleOverlay;

  HookeDecorator({
    this.length = 100,
    this.k = 0.003,
    super.sameTagsFactor = 1,
    this.handleOverlay,
    this.degreeFactor,
  });

  Vector2 hooke(Vertex s, Vertex d, Graph graph) {
    var len = degreeFactor?.call(length, d.neighborEdges.length) ?? length;
    var delta = s.position - d.position;
    var distance = delta.length;
    var force = -(distance - len - log(s.degree + d.degree)) * k;
    return delta * force;
  }

  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {
    for (var n in v.neighbors) {
      if (v.position != Vector2.zero() && n.position != Vector2.zero()) {
        var force = hooke(v, n, graph);
        setForceMap(v, n, force);
      }
    }
  }


  @override
  String get isolateFuncWorkerName => "HOOKE_ISOLATE_FUNC";

  @override
  void Function(dynamic params) get isolateAttachFunc => isolateFunc;

  @pragma('vm:entry-point')
  @isolateManagerCustomWorker
  static void isolateFunc(dynamic params) {
    IsolateManagerFunction.customFunction<ComputeRes, Map<String, dynamic>>(
      params,
      onEvent: (controller, jsonInput) {
        final perVertexCalcMap = ComputeRes();

        // extract parameters from json input
        double k = jsonInput["decorator"]["params"]["k"];
        double length = jsonInput["decorator"]["params"]["length"];
        Map<String, Map<String, dynamic>> vertexMap = jsonInput["graph"]["vertexes"];
        List<Map<String, dynamic>> vertexes = vertexMap.values.toList();

        // initialize per vertex map with 0 forces
        for (final v in vertexes) {
          perVertexCalcMap[v["id"]] = Vector2.zero();
        }

        // compute forces
        for (final v in vertexes) {
          for (var nId in v["neighbors"]) {
            Map<String, dynamic> n = vertexMap[nId]!;
            if (v["position"] != Vector2.zero()
                && n["position"] != Vector2.zero()
                && v["id"] != n["id"]
            ) {
              var hookRes = hookeRaw(v, n, length, k);
              // final vDeg = max(v["degree"], 2.0);
              final vDeg = max(v["degree"], 1.0);
              // final nDeg = max(n["degree"], 1.0);
              // perVertexCalcMap[v["id"]] += hookRes/(vertexes.length*1.0); // bad...weak
              // perVertexCalcMap[v["id"]] += hookRes/sqrt(vertexes.length*1.0); // bad...weak
              // perVertexCalcMap[v["id"]] += hookRes/(vDeg * log(vDeg)); // bad...weak
              // perVertexCalcMap[v["id"]] += hookRes/(vDeg * sqrt(vertexes.length)); // fine
              perVertexCalcMap[v["id"]] += hookRes/(vDeg * log(vertexes.length)); // fine
              // perVertexCalcMap[v["id"]] += hookRes/(vDeg); // fine
              // perVertexCalcMap[v["id"]] += hookRes/log(vDeg*vertexes.length); // bad...strong
              // perVertexCalcMap[v["id"]] += hookRes/(log(vertexes.length)); // bad...strong
              // perVertexCalcMap[v["id"]] += hookRes/(log(vDeg * vDeg)); //bad...strong
              // perVertexCalcMap[v["id"]] += hookRes;
            }
          }
        }

        return perVertexCalcMap;
      },
      autoHandleException: true, // Set to true to let IsolateManager handle basic errors
      autoHandleResult: true,    // Set to true to let IsolateManager handle basic result sending
    );
  }

  /// compute hooke force between two vertices
  static Vector2 hookeRaw(
      Map<String, dynamic> s,
      Map<String, dynamic> d,
      double length,
      double k) {
    // var len = degreeFactor?.call(length, d.neighborEdges.length) ?? length;
    var len = length;
    var delta = s["position"] - d["position"];
    var distance = delta.length;
    var force = -(distance - len - log(s["degree"] + d["degree"])) * k;
    return delta * force;
  }



  @override
  Map<String, dynamic> serialize({Map<String, dynamic> params = const {}}) {
    return super.serialize(params: {
      "k": k,
      "length": length,
      "sameTagsFactor": sameTagsFactor,
    });
  }
}
