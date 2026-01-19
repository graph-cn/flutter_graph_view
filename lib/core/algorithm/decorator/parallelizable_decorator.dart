
import 'package:flutter_graph_view/core/graph_algorithm.dart';

/// A [ForceDecorator] that can be added to [ParallelizationDecorator]
abstract interface class ParallelizableDecorator{
  /// The equivalent of a [GraphAlgorithm.compute] that
  // ComputeRes computeRaw(List<Map<String, dynamic>> vertexList, Map<String, dynamic> graph);

  /// see [GraphAlgorithm.serialize]
  Map<String,dynamic> serialize({Map<String, dynamic> params = const {}});
  /// The Isolate Function Name used so that isolates work as Javascript workers
  /// look into isolate_manager package for more details
  String get isolateFuncWorkerName;
  /// A pointer to a static function inside the inheriting class that is
  /// responsible for the isolate. The parallelization entrypoint,
  /// deserialization, and calculations live here. A sample is as follows:
  ///
  /// ```dart
  ///  @override
  ///   void Function(dynamic) get isolateAttachFunc => isolateFunc;
  ///
  ///   @pragma('vm:entry-point')
  ///   @isolateManagerCustomWorker
  ///   static void isolateFunc(dynamic params) {
  ///     IsolateManagerFunction.customFunction<ComputeRes, Map<String, dynamic>>(
  ///       params,
  ///       onEvent: (controller, jsonInput) {
  ///         final perVertexCalcMap = ComputeRes();
  ///
  ///         double k = jsonInput["decorator"]["params"]["k"];
  ///         Map<String, Map<String, dynamic>> vertexMap = jsonInput["graph"]["vertexes"];
  ///         List<Map<String, dynamic>> vertexes = vertexMap.values.toList();
  ///
  ///         for (var v in vertexes) {
  ///           perVertexCalcMap[v["id"]] = Vector2.zero();
  ///         }
  ///
  ///         for (int i = 0; i < vertexes.length; i++) {
  ///           for (int j = i+1; j < vertexes.length; j++) {
  ///             final v = vertexes[i];
  ///             final gv = vertexes[j];
  ///
  ///             Vector2 vPos = v["position"];
  ///             Vector2 gvPos = gv["position"];
  ///             if (v["id"] !=gv["id"] &&
  ///                 vPos != Vector2.zero() &&
  ///                 gvPos != Vector2.zero()
  ///             ) {
  ///               // F = k * q1 * q2 / r^2
  ///               final delta = vPos - gvPos;
  ///               final distance = delta.length;
  ///               final vDeg = max(v["degree"]-1, 1);
  ///               final vGDeg = max(gv["degree"]-1, 1);
  ///               final force = k * vDeg * vGDeg / max((distance * distance), 1);
  ///               // final force = k  / (max((distance * distance), 1) * log(vDeg) * log(vGDeg));
  ///
  ///               perVertexCalcMap[v["id"]] += delta * force;
  ///               perVertexCalcMap[gv["id"]] += -delta * force;
  ///             }
  ///           }
  ///         }
  ///
  ///         return perVertexCalcMap;
  ///       },
  ///       // onInit: (controller) {
  ///       //   print('Custom Fibonacci Worker: Initialized');
  ///       //   // Perform any setup logic here
  ///       // },
  ///       // onDispose: (controller) {
  ///       //   print('Custom Fibonacci Worker: Disposed');
  ///       //   // Perform any cleanup logic here
  ///       // },
  ///       autoHandleException: true, // Set to true to let IsolateManager handle basic errors
  ///       autoHandleResult: true,    // Set to true to let IsolateManager handle basic result sending
  ///     );
  ///   }
  /// ```
  void Function(dynamic params) get isolateAttachFunc;
}
