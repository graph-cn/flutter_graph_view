import 'package:flutter/foundation.dart';
import 'package:flutter_graph_view/core/algorithm/decorator/parallelizable_decorator.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:intl/intl.dart';
import 'package:isolate_manager/isolate_manager.dart';


/// A GraphAlgorithm that runs force-directed layout in a background isolates.
/// Please note that because paralleli
///
/// Each child decorator will run in a single dedicated isolate. This is to
/// decouple the drawing logic from the calculation logic. It is different than
/// parallelizing
class ParallelizationDecorator extends ForceDecorator {
  
  /// isolate managers that will run to return Computation results for child 
  /// parallelizable decorators
  final List<IsolateManager<ComputeRes, Map<String, dynamic>>> _isolateManagers
    = [];

  /// used to count and log which graph compute cycle this class is on. this
  /// number will be incremented when all calculations of all isolates are done
  /// and when the force map of the vertexes is updated 
  var _currCycle = 0;

  /// used to count and log how much time the current graph compute cycle took.
  /// This will be reset when all calculations of all isolates are done
  /// and when the force map of the vertexes is updated
  static DateTime _perCycleTimestamp = DateTime.now();
  
  /// List of all decorators to be run in parallel. This class only supports
  /// ParallelizableDecorator children
  List<ParallelizableDecorator> pDecorators;

  @override
  /// convenient getter
  List<GraphAlgorithm> get decorators => pDecorators.map(
      (d) => d as GraphAlgorithm
  ).toList();

  /// A map that links each Isolate to its equivalent ParallelizableDecorator
  final _isoDecoMap = <IsolateManager, ParallelizableDecorator>{};

  ParallelizationDecorator({this.pDecorators = const []});

  /// Once the entire graph is loaded or reloaded, remove the old isolates and
  /// add new ones
  @override
  void setGlobalData({
    required GraphAlgorithm rootAlg,
    required Graph graph,
  }) async {
    super.setGlobalData(rootAlg: rootAlg, graph: graph);

    // stop and cleanup all old isolates
    for (var iso in _isolateManagers) {
      await iso.stop();
    }
    _isolateManagers.clear();
    _isoDecoMap.clear();

    // create new isolates for each parallel decorator using the decorator's
    // internal logic
    for (var pd in pDecorators) {
      IsolateManager<ComputeRes, Map<String, dynamic>> iso =
        IsolateManager.createCustom(
          pd.isolateAttachFunc, // The function this isolate is dedicated to
          workerName: pd.isolateFuncWorkerName, // For JS worker support.
          concurrent: 1, // 1 isolate per child decorator
          isDebug: false, // for more logging
          queueStrategy: RejectIncomingStrategy(maxCount: 10) // prevents memory overflow
        );
      _isolateManagers.add(iso);
      _isoDecoMap[iso] = pd;
    }
  }


  /// Object that holds data regarding the isolate calculations as a cumulative
  final ParallelCalc<Map<String, Vector2>> _parallelCalcRes = ParallelCalc();

  // start the background simulation.
  @override
  /// ignore: call parent
  Future<void> compute(Vertex _, Graph graph) async {
    // if paused, then don't run calculations
    if(graph.options!.pause.value) {
      return;
    }

    // if the background calculations are already running for this graph cycle,
    // don't start a new isolate batch
    if(_parallelCalcRes.alreadyRunning) {
      return;
    }

    // prevent multiple computes of the same isolate
    _parallelCalcRes.alreadyRunning = true;

    try {
      for (var iso in _isolateManagers) {
        _parallelCalcRes.addSingleCalc(iso);
      }
        
      for (var iso in _isolateManagers) {
        // used for logging time took for this isolate
        var singleCalcStartTime = DateTime.now();
        // do the cal
        iso.compute({
          "decorator" : _isoDecoMap[iso]!.serialize(),
          // "vertex" : tempVertexList.map((v) => v.toJson()).toList(),
          "graph" : graph.serialize()
        }, callback: (res) {
          _parallelCalcRes.saveResult(iso, res);
          // print how much time a single run took
          // if (kDebugMode) {
          //   print("single calc time (${_isoDecoMap[iso]!.runtimeType}): ${
          //     NumberFormat('#,##0.00').format(DateTime.now().difference(singleCalcStartTime).inMicroseconds / 1000.0)
          //   }");
          // }

          if(_parallelCalcRes.allCalcsDone){
            // accumulate forces of all calculations
            Map<String, Vector2> totalForcePerVertex = {};
            for (var resMap in _parallelCalcRes.accruedRes.values) {
              for (var res in resMap.entries) {
                totalForcePerVertex.addOrSet(res.key, res.value);
              }
            }

            // apply forces
            var vMap = graph.vertexByIdMap;
            totalForcePerVertex.forEach((key, force) {
              setForceMap(vMap[key]!, vMap[key]!, force);
            });

            // print how much time all parallel runs took
            // if (kDebugMode) {
            //   print("----------Frame: $_currCycle - parallel calc time: ${
            //     NumberFormat('#,##0.00').format(DateTime.now().difference(_perCycleTimestamp).inMicroseconds / 1000.0)
            //   }");
            // }

            // update state for next cycle
            _currCycle++;
            _perCycleTimestamp = DateTime.now();
            _parallelCalcRes.reset();
          }
          // tell the compute command that this is a final result
          return true;
        });
      }
    } on IsolateException catch (e, st) {
      graph.options!.pause.value = true;
      if (kDebugMode) {
        print('Caught IsolateException: ${e.error} \n $st');
      }
      for (var iso in _isolateManagers) {
        await iso.stop();
      }
    } catch (e, st) {
      graph.options!.pause.value = true;
      if (kDebugMode) {
        print('Caught other error: $e \n $st');
      }
      for (var iso in _isolateManagers) {
        await iso.stop();
      }
    }

    // Do nothing. This runs each frame for each vertex,
    // but we've offloaded calculations, so just return immediately.
  }




  /// Clean up the isolate when the algorithm (graph) is disposed.
  Future<void> dispose() async {
    try {
      for (var iso in _isolateManagers) {
        await iso.stop();
      }
    } catch (_) {
      // If sending fails, just kill the isolate
    }
    // _isolate?.kill(priority: Isolate.immediate);
  }
}


/// the state of the all parallel calculations as a whole
class ParallelCalc<T>{
  /// states whether the Parallel Calculation is already in progress
  bool alreadyRunning = false;
  /// holds a bool dedicated to each isolate. each bool states whether that
  /// isolate is done
  Map<IsolateManager, bool> doneMap = {};
  /// List of Maps that Hold the accrued Results of all isolates. Each map holds
  /// the result of a single isolate
  Map<IsolateManager, T> accruedRes = {};


  ParallelCalc();

  /// all calculations are done
  get allCalcsDone =>
      doneMap.values.every((isDone) => isDone);

  /// stores the result of each isolate after it is done and flags it as done
  saveResult(IsolateManager currIso, T res){
    doneMap[currIso] = true;
    accruedRes[currIso] = res;
  }

  /// adds an isolate and sets it to not done.
  /// 
  /// Be sure to run this for all your isolates before you compute them, because 
  /// only IsolateManagers added will be tested if they are done. If you do not,
  /// an already started isolate might complete before you added the rest of 
  /// your isolates and might change the answer of `allCalcsDone`
  void addSingleCalc(IsolateManager<T, Map<String, dynamic>> iso){
    doneMap[iso] = false;
  }

  /// clear out all data
  reset(){
    doneMap.clear();
    accruedRes.clear();
    alreadyRunning = false;
  }
}
