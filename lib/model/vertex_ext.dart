import 'package:flutter_graph_view/flutter_graph_view.dart';

// properties keys
const String _velocityKey = "VELOCITY";
const String _forceKey = "force";
const String _timeCounterKey = "timeCounter";

// vertex keys
const String _id = "id";
const String _position = "position";
const String _radius = "radius";
const String _tag = "tag";
const String _tags = "tags";
const String _neighbors = "neighbors";
const String _degree = "degree";

/// extension for [Vertex]. It standardizes access to common properties, and
/// adds type safety
extension VertexExt on Vertex {
  /// the speed/direction at which the vertex is currently moving at. This is
  /// useful it you want to add acceleration to the [ForceMotionDecorators].
  Vector2 get velocity => properties[_velocityKey];
  set velocity(Vector2 value) => properties[_velocityKey] = value;

  /// the total force exerted on a Vertex
  Vector2 get force => properties[_forceKey] ?? Vector2.zero();
  set force(Vector2 value) => properties[_forceKey] = value;


  int get timeCounter => properties[_timeCounterKey];
}

/// extension type for map that represents a [Vertex]. It adds type
/// safety and makes it easier to work with the map representation. This has no
/// overhead since "extension type" is not a class and is never instantiated. It
/// is only a wrapper type.
extension type RawVertex(Map<String, dynamic> _m){
  // id
  String get id => _m[_id];
  set id(String value) => _m[_id] = value;

  // position
  Vector2 get position => _m[_position];
  set position(Vector2 value) => _m[_position] = value;

  // radius
  double get radius => _m[_radius];
  set radius(double value) => _m[_radius] = value;

  // tag
  String get tag => _m[_tag];
  set tag(String value) => _m[_tag] = value;

  // tags
  List<String> get tags => _m[_tags];
  set tags(List<String> value) => _m[_tags] = value;

  List<String> get neighbors => _m[_neighbors];
  set neighbors(List<String> value) => _m[_neighbors] = value;

  int get degree => _m[_degree];
  set degree(int value) => _m[_degree] = value;

  Vector2 get velocity => _m[_velocityKey];
  set velocity(Vector2 value) => _m[_velocityKey] = value;

  Vector2 get force => _m[_forceKey] ?? Vector2.zero();
  set force(Vector2 value) => _m[_forceKey] = value;
}



