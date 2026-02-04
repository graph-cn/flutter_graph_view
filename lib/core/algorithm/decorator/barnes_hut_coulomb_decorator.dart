import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';
import 'package:intl/intl.dart';
import 'package:isolate_manager/isolate_manager.dart';

/// Barnes–Hut Algorithm
///
/// This decorator implements the Barnes–Hut approximation for repulsive
/// forces, and is an optimized alternative to [CoulombDecorator].
///
/// While the Coulomb algorithm computes pairwise repulsion in O(n²) time,
/// Barnes–Hut reduces the complexity to O(n log n) by approximating the
/// influence of distant vertices. This provides a significant performance
/// improvement at the cost of reduced accuracy.
///
/// Please note that this decorator has a lot of overhear before it starts. This
/// will affect at which Graph size this decorator becomes better than
/// [CoulombDecorator]. Try out the demo to check for yourself. be sure to
/// enable logging flag [ParallelizationDecorator.logCycleDuration] if you are
/// using it to see which is better for you
///
///
/// How the algorithm works
/// -----------------------
///
/// The graph is spatially partitioned into a **quadtree**:
/// - Each node in the quadtree represents a rectangular region (quadrant).
/// - Each quadrant may have up to four children.
/// - The root quadrant covers the entire graph.
///
/// Each quadrant stores the **center of mass (COM)** of all vertices contained
/// within it.
///
/// When computing the repulsive force on a vertex:
/// - Nearby vertices are handled individually.
/// - Distant groups of vertices are approximated as a single mass located at
///   the quadrant’s center of mass.
///
/// This allows the algorithm to replace many individual force calculations
/// with a single approximation when vertices are sufficiently far away.
///
///
/// Approximation criterion
/// -----------------------
///
/// For a given vertex and a quadtree quadrant (This calculation assumes
/// [softening] is 0):
///
/// - `vPos` = position of the current vertex
/// - `com`  = center of mass of the quadrant
/// - `w`    = width of the quadrant bounds
/// - `h`    = height of the quadrant bounds
/// - `s`    = characteristic size of the quadrant
///            (typically `max(w, h)` or `(w + h) / 2`)
/// - `d`    = distance between `vPos` and `com`
///
/// The Barnes–Hut criterion is:
///
/// ```text
/// s / d < theta
/// ```
///
/// - If the condition is **true**, the entire quadrant is treated as a single
///   mass and the force is computed once using its center of mass.
/// - If the condition is **false**, the quadrant is too close and its children
///   are evaluated recursively.
///
/// The parameter [theta] controls the accuracy–performance tradeoff:
/// - Smaller values yield more accurate results but higher cost.
/// - Larger values increase performance but reduce accuracy.
///
///
/// Notes
/// -----
/// - This implementation supports parallel execution via [ParallelizationDecorator].
/// - A serial (non-parallel) version is not yet implemented.
///
///
/// See also
/// --------
/// - [CoulombDecorator] for the exact O(n²) force calculation.
///
class BarnesHutDecorator extends ForceDecorator implements ParallelizableDecorator {
  /// Strength of the repulsive force.
  ///
  /// This value scales the magnitude of the Coulomb-like repulsion applied
  /// between vertices. Larger values result in stronger repulsion and a more
  /// spread-out layout.
  double k;

  /// Barnes–Hut opening angle threshold.
  ///
  /// This parameter controls when a quadtree quadrant is treated as a single
  /// mass versus when it is recursively subdivided.
  ///
  /// Smaller values increase accuracy but reduce performance.
  /// Larger values improve performance at the cost of accuracy.
  ///
  /// ⚠️ **Warning:**
  /// Values greater than `0.5` may significantly reduce accuracy and can cause
  /// unstable or visually incorrect layouts, especially for dense graphs.
  double theta;

  /// Distance softening factor.
  ///
  /// A small constant added to the squared distance between vertices to
  /// prevent numerical instability and division-by-zero when vertices are
  /// extremely close or overlapping.
  double softening;

  /// Root node of the Barnes–Hut quadtree.
  ///
  /// This quadtree spatially partitions the graph and stores center-of-mass
  /// information used to approximate repulsive forces.
  _QuadTreeNode? _root;

  /// Bounding rectangle of the quadtree.
  ///
  /// This defines the spatial extent of the graph used to build the quadtree.
  /// It is typically recomputed each iteration based on the current vertex
  /// positions.
  Rect _bounds;

  /// only for testing
  // double fullGraphMass = 0.0;

  /// since this algorithm's efficiency changes with time and graph shape,
  /// enabling this will print out how many calculations were skipped in
  /// comparison with [CoulombDecorator]. Use it to decide which algorithm is
  /// better for you. This will only work in kDebugMode
  final bool logCalculationsSkipped;
  /// the numbr of calculations skipped in comparison with [CoulombDecorator].
  /// the total calculations would have been (Graph.length)²/2 for
  /// [CoulombDecorator]
  var _skippedCalcs = 0;


  BarnesHutDecorator({
    this.k = 100.0,
    this.theta = 0.5,
    this.softening = 1.0,
    Rect? initialBounds,
    this.logCalculationsSkipped = false
  }) :
  _bounds = initialBounds ?? Rect.fromLTWH(-500, -500, 500, 500);




  void computeBoundsAndCenterOfMass(List<RawVertex> vertexList) {
    // Recompute the quadtree bounds dynamically (e.g., bounding box of all vertices)
    // fullGraphMass = vertexList.fold(0, (prev, currV) => prev + currV.radius);
    _bounds = _computeBounds(vertexList);

    // average side of subquadrants
    final averageSide = (_bounds.width + _bounds.height) / 2.0;

    _root = _QuadTreeNode(this, _bounds, averageSide);

    // Insert all vertices into the quadtree
    for (final v in vertexList) {
      _root!.insert(v);
    }
    // Compute center of mass for each quadtree cell recursively
    _root!.computeCenterOfMass();
  }

  @override
  void compute(Vertex v, Graph graph) {
    throw UnimplementedError("BarnesHutDecorator is not intended to be run in "
        "series yet. To use this decorator in parallel, place it in a "
        "ParallelizationDecorator");
    super.compute(v, graph);
  }



  // Compute the bounding box of all nodes (for quadtree root)
  Rect _computeBounds(List<RawVertex> vertexList) {
    if (vertexList.isEmpty) return _bounds;
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    for (final v in vertexList) {
      final pos = v.position;
      if (pos.x < minX) minX = pos.x;
      if (pos.x > maxX) maxX = pos.x;
      if (pos.y < minY) minY = pos.y;
      if (pos.y > maxY) maxY = pos.y;
    }
    // Add a margin to bounds
    double width = maxX - minX;
    double height = maxY - minY;
    if (width == 0) width = 1;
    if (height == 0) height = 1;
    return Rect.fromLTWH(minX, minY, width, height);
  }

  void accumulateForceOn(RawVertex v) {
    _root?.accumulateForceOn(v, v.position/v.radius, theta, softening);
  }


// @override
// ComputeRes computeRaw(List<Map<String, dynamic>> vertexList, Map<String, dynamic> graph) {
//   final perVertexCalcMap = ComputeRes();
//   // for (final v in vertexList) {
//   //   perVertexCalcMap[v["id"] as String] = Vector2.zero();
//   // }
//
//   for (final v in vertexList) {
//     for (var n in v["neighbors"]) {
//       if (v["position"] != Vector2.zero() && n["position"] != Vector2.zero()) {
//         perVertexCalcMap[(v["id"], n["id"])]
//         = hookeRaw(v, n, graph);
//       }
//     }
//   }
//   final childForces = super.computeRaw(vertexList, graph);
//   for (final keys in perVertexCalcMap.keys){
//     childForces[keys] = childForces.containsKey(keys)
//         ? childForces[keys] + perVertexCalcMap[keys]!
//         : perVertexCalcMap[keys]!;
//   }
//   return perVertexCalcMap;
// }

  @override
  Map<String, dynamic> serialize({Map<String, dynamic> params = const {}}) {
    return super.serialize(params: {
      "k": k,
      "theta": theta,
      "softening": softening,
      "logCalculationsSkipped": logCalculationsSkipped
    });
  }

  @override
  String get isolateFuncWorkerName => "BARNS_HUT_ISOLATE_FUNC";

  @override
  void Function(dynamic) get isolateAttachFunc => isolateFunc;


  /// The actual calculation is done inside here
  @pragma('vm:entry-point')
  @isolateManagerCustomWorker
  static void isolateFunc(dynamic params) {
    IsolateManagerFunction.customFunction<ComputeRes, Map<String, dynamic>>(
      params,
      onEvent: (controller, jsonInput) {

        // extract parameters from json input
        double k = jsonInput["decorator"]["params"]["k"];
        double theta = jsonInput["decorator"]["params"]["theta"];
        double softening = jsonInput["decorator"]["params"]["softening"];
        bool logCalculationsSkipped = jsonInput["decorator"]["params"]["logCalculationsSkipped"];
        Map<String, Map<String,dynamic>> vertexMap = jsonInput["graph"]["vertexes"];
        List<RawVertex> vertexes = vertexMap.values.map<RawVertex>((v) => RawVertex(v)).toList();

        // recreate the decorator in the isolate
        var bhDec = BarnesHutDecorator(
          k: k,
          theta: theta,
          softening: softening,
          logCalculationsSkipped: logCalculationsSkipped,
        );

        bhDec.computeBoundsAndCenterOfMass(vertexes);

        // test to see if the quadtree is working and filled correctly
        // missing vertexes should be empty
        // List<RawVertex> missingVertexes = [];
        // for (var v in vertexes) {
        //   if(!bhDec._root!.vertexExists(v)){
        //     missingVertexes.add(v);
        //   }
        // }
        for (var v in vertexes) {
          bhDec.accumulateForceOn(v);
        }

        // log how many calculations were skipped
        if(kDebugMode) {
          if(bhDec.logCalculationsSkipped) {
            debugPrint("BarnsHutDecorator: Skipped vs Coulomb: ${
                NumberFormat('#,##0 Calculations').format(bhDec._skippedCalcs)}");
          }
        }

        return { for(var v in vertexes) v.id: v.force * k};
      },
      autoHandleException: true, // Set to true to let IsolateManager handle basic errors
      autoHandleResult: true,    // Set to true to let IsolateManager handle basic result sending
    );
  }

  /// for testing only
  // static void compareMasses(BarnesHutDecorator bhDec, List<RawVertex> vertexes) {
  //   _QuadTreeNode current = bhDec._root!;
  //
  //   double vMass = 0;
  //   double qMass = 0;
  //   for(var v in vertexes) {
  //     vMass+=v.radius;
  //     main_loop: while (true) {
  //       // Case 1: current node is a leaf
  //       if (current.isLeaf) {
  //         if (current.point != null) {
  //           qMass += current.mass;
  //           if(current.mass != v.radius){
  //             print("there was an error ${current.point!.id} - ${v.id}: ${current.mass} != ${v.radius}");
  //           }
  //         }
  //         break main_loop;
  //       }
  //
  //       // Case 2: internal node → descend
  //       current = current._childFor(v);
  //     }
  //   }
  //   bool massesMatch = vMass == qMass;
  //   if(!massesMatch){
  //     print("masses don't match ${vMass} != ${qMass}");
  //   }
  // }

}

/// Internal quadtree node class
class _QuadTreeNode {
  /// bounding box of this node
  final Rect bounds;
  /// average side length of quadrant
  final double boundsAverageSide;
  /// center of bounds: x axis
  final double boundsMidX;
  /// center of bounds: y axis
  final double boundsMidY;
  /// ref to the decorator
  final BarnesHutDecorator decorator;
  /// Center-of-mass location
  Vector2 com = Vector2.zero();
  /// mass of this node. The Vertex radius is used as the mass.
  double mass = 0;
  /// number of points stored in this node and its children. This number is only
  /// used for logging purposes and will be ignored otherwise to improve
  /// performance.
  double count = 0;
  /// Child quadtree nodes (NW, NE, SW, SE)
  _QuadTreeNode? nw, ne, sw, se;
  /// Point stored in this node (only if this is a leaf node).
  RawVertex? point;

  /// Whether this node is a leaf (has no children)
  bool get isLeaf => nw == null && ne == null && sw == null && se == null;

  _QuadTreeNode(
      this.decorator,
      this.bounds,
      this.boundsAverageSide
  ):
    boundsMidX = bounds.left + bounds.width / 2,
    boundsMidY = bounds.top + bounds.height / 2
  ;

  /// insert a raw vertex into the quadtree
  void insert(RawVertex v) {
    _QuadTreeNode current = this;

    while (true) {
      // Case 1: current node is a leaf
      if (current.isLeaf) {
        if (current.point == null) {
          // Empty leaf: store point and stop
          current.addPoint(v);
          return;
        } else {
          // Leaf already has a point → subdivide
          final RawVertex existing = current.point!;
          current.point = null;
          current.mass = 0;
          current.com = Vector2.zero();
          current._subdivide();

          // find the correct child to insert into and reinsert the old point
          final childForExisting = current._childFor(existing);
          childForExisting.addPoint(existing);

          // the current node is not a leaf anymore and will descended into
        }
      }

      // Case 2: internal node → descend
      current = current._childFor(v);
    }
  }

  /// Subdivide this node into four children (NW, NE, SW, SE)
  void _subdivide() {
    final halfWidth = bounds.width / 2;
    final halfHeight = bounds.height / 2;
    final x = bounds.left;
    final y = bounds.top;

    final boundsAverageSide = this.boundsAverageSide / 2.0;

    // Create four child quadrants
    nw = _QuadTreeNode(decorator, Rect.fromLTWH(x, y, halfWidth, halfHeight), boundsAverageSide);
    ne = _QuadTreeNode(decorator, Rect.fromLTWH(x + halfWidth, y, halfWidth, halfHeight), boundsAverageSide);
    sw = _QuadTreeNode(decorator, Rect.fromLTWH(x, y + halfHeight, halfWidth, halfHeight), boundsAverageSide);
    se = _QuadTreeNode(decorator, Rect.fromLTWH(x + halfWidth, y + halfHeight, halfWidth, halfHeight), boundsAverageSide);
  }

  /// get which subquadrant does the raw vertex belong to
  _QuadTreeNode _childFor(RawVertex v) {
    final px = v.position.x;
    final py = v.position.y;

    if (py < boundsMidY) {
      return (px < boundsMidX)
          ? nw!
          : ne!;
    } else {
      return (px < boundsMidX)
          ? sw!
          : se!;
    }
  }

  /// add the point and its properties to the current quadrant
  void addPoint(RawVertex v) {
    if(kDebugMode) {
      if(decorator.logCalculationsSkipped) {
        count++;
      }
    }
    point = v;
    mass = v.radius;
    com = v.position / v.radius;
  }

  /// Compute center-of-mass for this node and its children
  void computeCenterOfMass() {
    // Leaf: already has its own mass (point’s position counted in massX/massY)
    if (isLeaf) {
      return;
    }

    // Reset mass and center-of-mass
    mass = 0;
    com = Vector2.zero();
    if(kDebugMode) {
      if(decorator.logCalculationsSkipped) {
        count = 0;
      }
    }

    // Accumulate from children
    double existingChildQuad = 0;
    for (var child in [nw, ne, sw, se]) {
      // ignore null and massless children
      if (child == null) {
        continue;
      }
      child.computeCenterOfMass();
      if (child.mass == 0) {
        continue;
      }
      existingChildQuad++;

      com += child.com;
      mass += child.mass;
      // update count
      if(kDebugMode) {
        if(decorator.logCalculationsSkipped) {
          count += child.count;
        }
      }
    }
    if (mass > 0) {
      // Compute actual center-of-mass (average position)
      com /= existingChildQuad;
    }
  }


  /// check if a vertex exists in the quadtree
  bool vertexExists(RawVertex v) {
    if (isLeaf) {
      if (point == null) {
        return false;
      } else {
        return point!.id == v.id;
      }
    }
    else {
      var vertexFound = false;
      for (var child in [nw, ne, sw, se]) {
        if (child == null) {
          continue;
        }
        vertexFound |= child.vertexExists(v);
      }
      return vertexFound;
    }
  }

  /// Recursively accumulate force on vertex v from this quadtree node
  void accumulateForceOn(RawVertex v, Vector2 vCom, double theta, double softening2) {
    // Empty node or self-point: no force contribution
    if (mass == 0 || (point?.id == v.id && isLeaf)) {
      return;
    }

    final diff = vCom - com;
    final dist2 = diff.length2 + softening2;

    // if Leaf node (with a point that is not v)
    // or if far enough or no further subdivision, treat this quadrant as one mass
    // then use direct calculation
    if (isLeaf || boundsAverageSide / sqrt(dist2) < theta) {
      // _addRepulsiveForce(v, diff, dist2);
      v.force += diff / dist2;
      // add how many calculations were skipped. `-1` for the calc that we
      // actually did
      if(kDebugMode) {
        if(decorator.logCalculationsSkipped) {
          decorator._skippedCalcs += count.toInt()-1;
        }
      }
    } else {
      // Need to open this cell and consider children separately
      nw?.accumulateForceOn(v, vCom, theta, softening2);
      ne?.accumulateForceOn(v, vCom, theta, softening2);
      sw?.accumulateForceOn(v, vCom, theta, softening2);
      se?.accumulateForceOn(v, vCom, theta, softening2);
    }
  }

  // Add Coulomb repulsive force between v and a source at (v.pos + dx, v.pos + dy) with given squared distance
  // void _addRepulsiveForce(RawVertex v, Vector2 diff, double dist2) {
  //   final force = 1 / dist2; // Coulomb's law: F ∝ 1/r^2, unit charge
  //   // final force = 1 / sqrt(dist2); // Coulomb's law: F ∝ 1/r^2, unit charge
  //   // final mag = force * v.radius * mass; // since we are not multiplying by any charge constant here
  //   // final mag = force; // since we are not multiplying by any charge constant here
  //   // v.force += -diff * mag;
  //   v.force += diff * force;
  // }
}
