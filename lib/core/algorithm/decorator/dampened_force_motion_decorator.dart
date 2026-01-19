import 'package:flutter/foundation.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelization_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:intl/intl.dart';

/// A Decorator that translates the calculated forces on graph vertexes into 
/// motion. This decorator reads and updates vertex velocity while damping it.
/// You can think of damping as friction on a moving car; if no force (acceleration) is
/// applied on the car, it will eventually stop. This decorator also scales down
/// the effects of new forces with each graph cycle. This gets rid of
/// oscillation when the graph doesn't naturally converge, or is too complex to
/// reach convergence on its own (google "three body problem").
///
/// As an extra. This decorator will not change the position of
///
/// Consider using this decorator instead of [ForceMotionDecorator] when your
/// graph doesn't converge on its own, or when you want to reach equilibrium
/// faster.
///
/// Context: this class was created when [ParallelizationDecorator] was
/// introduced. The nature of using graph snapshots (per graph cycle) instead of
/// continuous graph updating (per vertex) introduces a lot of inaccuracy to
/// each graph calculation cycle, especially in bigger graphs. This is generally
/// visible as oscillations or vertex orbiting in the graph animation (according
/// to my testing). Increasingly damping these oscillations eventually makes you
/// reach an acceptable result.
class DampenedForceMotionDecorator extends ForceMotionDecorator {
  /// velocity damping factor per cycle (e.g. 0.90). change this to slow down
  /// already existing velocity inside the graph. Similar to friction in physics
  double damping;
  /// scale on new forces. This gets rid of oscillation when the graph doesn't
  /// naturally converge, or is too complex to reach convergence on its own
  double _scaling;
  /// minimum timestep to cool down to
  double minTimestep;
  /// multiply [_scaling] by this each cycle (cooling). scaling is clamped to
  /// [minTimestep]
  double coolingFactor;
  /// threshold for max movement (px) to consider the graph as converged/stable
  double stopTolerance;
  /// number of graph cycles with max of the per-vertex movements is below
  /// [stopTolerance] before stopping
  int stableCyclesThreshold;
  /// IDs of vertices to pin (freeze)
  Set<dynamic> pinnedVertexIds;

  // Internal state
  /// how many Graph Cycles has the vertexes not moved above the [stopTolerance]
  /// look at [stableCyclesThreshold]
  int _stableCycleCount = 0;
  /// the max movement any vertex did this graph cycle
  double _maxMove = double.negativeInfinity;

  /// Logging

  /// only used for logging the time it took for the graph to reach stability.
  /// whether to start the stability timer
  bool _firstComputeRun = true;
  /// only used for logging the time it took for the graph to reach stability
  /// whether to log the time it took for the graph to reach stability
  bool logTimeToStability = true;
  /// only used for logging the time it took for the graph to reach stability
  /// whether to log the max movement this cycle
  bool logMaxMoveThisCycle = true;
  /// only used for logging the time it took for the graph to reach stability
  static DateTime _computeStartTimestamp = DateTime.now();



  DampenedForceMotionDecorator({
    this.damping = 0.98,
    double initialTimestep = 1.0,
    this.minTimestep = 0.02,
    this.coolingFactor = 0.997,
    this.stopTolerance = 1.0,
    this.stableCyclesThreshold = 30,
    Set<dynamic>? pinned,
    this.logMaxMoveThisCycle = false,
    this.logTimeToStability = false,
  }) :
        pinnedVertexIds = pinned ?? {}, 
        _scaling=initialTimestep;




  @override
  // ignore: must_call_super
  void compute(Vertex v, Graph graph) {

    /// used for logging the time it took for the graph to reach stability
    if (kDebugMode) {
      if (logTimeToStability && _firstComputeRun) {
        _computeStartTimestamp = DateTime.now();
        _firstComputeRun = false;
      }
    }
    if (pinnedVertexIds.contains(v.id)) {
      // Freeze pinned vertex: zero out force and velocity, skip position update
      v.velocity = Vector2.zero();
      return;
    }
    if (v == graph.hoverVertex) {
      v.velocity = Vector2.zero();
      return;
    }

    // Apply damping to existing velocity
    // final vDeg = max(v.degree-1, 1.0);
    v.velocity *= damping;
    // v.velocity *= damping / vDeg;
    // Update velocity by acceleration (force).
    // v.velocity += v.force * timestep;
    var a = v.force / v.radius;
    // Vector2 absForce = a.clone()..absolute();

    // update velocity by adding current acceleration
    v.velocity += (a - v.velocity) * _scaling;
    // v.velocity.clamp(-absForce, absForce);
    // Update position by velocity
    final oldPos = v.position.clone();
    v.position += v.velocity * _scaling;
    // Track max movement (distance moved this frame)
    // final moveDist = (v.vx * timestep).abs().clamp((v.vy * timestep).abs(), double.infinity);

    // update biggest position change to use in stability check
    final moveDist = (v.position - oldPos).length;
    if (moveDist > _maxMove) _maxMove = moveDist;

    // execute the below only once per graph cycle
    if(graph.vertexes.isEmpty || v != graph.vertexes.last ){
      return;
    }



    // Cool down the scaling factor
    if (_scaling > minTimestep) {
      _scaling *= coolingFactor;
      if (_scaling < minTimestep) _scaling = minTimestep;
    }

    // Check for stability (no significant movement)
    if (_maxMove < stopTolerance) {
      _stableCycleCount++;
    } else {
      _stableCycleCount = 0;
    }

    // print max graph movement per cycle
    if (kDebugMode) {
      if (logMaxMoveThisCycle && _stableCycleCount <= stableCyclesThreshold) {
        print("----------Max move this graph cycle"
            "${
            _maxMove < stopTolerance
                ? " (stable $_stableCycleCount/$stableCyclesThreshold)"
                : ""
        }"
            ": $_maxMove");
      }
    }

    // If stable for many frames, signal a stop
    if (_stableCycleCount > stableCyclesThreshold) {
      // Mark graph as converged (reached its final position).
      graph.options?.pause.value = true;
      if (kDebugMode) {
        if (logTimeToStability) {
          print("----------Cooldown time: ${
              NumberFormat('#,##0.00 ms').format(
                  DateTime.now().difference(_computeStartTimestamp)
                      .inMicroseconds / 1000.0)
          }");
        }
      }
    }

    // reset max distance moved for this graph cycle
    _maxMove = double.negativeInfinity;
  }

}
