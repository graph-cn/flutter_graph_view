import 'package:flutter_graph_view/flutter_graph_view.dart';

extension VertexExt on Vertex {
  static const String _velocityKey = "VELOCITY";
  static const String _forceKey = "force";
  static const String _timeCounterKey = "timeCounter";

  Vector2 get velocity => properties[_velocityKey];
  set velocity(Vector2 value) => properties[_velocityKey] = value;

  Vector2 get force => properties[_forceKey] ?? Vector2.zero();
  set force(Vector2 value) => properties[_forceKey] = value;

  int get timeCounter => properties[_timeCounterKey];
}