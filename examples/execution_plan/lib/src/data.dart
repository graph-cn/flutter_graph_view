// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:convert';

class ResultSet {
  bool success = true;

  ExecutionPlan? plan;
}

class ExecutionPlan {
  String? format;
  Map<int, int>? nodeIndexMap;
  int? optimizeTimeInUs;
  List<ExecutionPlanNode>? nodes;

  ExecutionPlan({
    this.format,
    this.nodeIndexMap,
    this.nodes,
  });
  factory ExecutionPlan.fromRawJson(String str) =>
      ExecutionPlan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExecutionPlan.fromJson(Map<String, dynamic> json) => ExecutionPlan(
        format: json["format"],
        nodeIndexMap: Map.from(json["nodeIndexMap"]!)
            .map((k, v) => MapEntry<int, int>(int.parse(k), v)),
        nodes: json["nodes"] == null
            ? []
            : List<ExecutionPlanNode>.from(
                json["nodes"]!.map((x) => ExecutionPlanNode.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "format": format,
        "nodeIndexMap": Map.from(nodeIndexMap!)
            .map((k, v) => MapEntry<String, dynamic>('$k', v)),
        "nodes": nodes == null
            ? []
            : List<dynamic>.from(nodes!.map((x) => x.toJson())),
      };
}

class ExecutionPlanNode {
  int? id;
  String? name;
  List<int>? dependencies;
  List<ExecutionPlanNodeDesc>? _description;

  List<ExecutionPlanNodeDesc>? get description => _description;

  set description(List<ExecutionPlanNodeDesc>? description) {
    _description = description;
    for (ExecutionPlanNodeDesc desc in description ?? []) {
      if (desc.name == "inputVar") {
        inputVar = desc.value;
        break;
      }
    }
  }

  String? inputVar;

  String? outputVar;
  List<ExecutionPlanNodeProfile>? profiles;

  ExecutionPlanNode({
    this.dependencies,
    this.id,
    this.name,
    this.outputVar,
    List<ExecutionPlanNodeDesc>? description,
    this.profiles,
  }) {
    this.description = description;
  }

  factory ExecutionPlanNode.fromRawJson(String str) =>
      ExecutionPlanNode.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExecutionPlanNode.fromJson(Map<String, dynamic> json) =>
      ExecutionPlanNode(
        dependencies: json["dependencies"] == null
            ? []
            : List<int>.from(json["dependencies"]!.map((x) => x)),
        id: json["id"],
        name: json["name"],
        outputVar: json["outputVar"],
        description: json["description"] == null
            ? []
            : List<ExecutionPlanNodeDesc>.from(json["description"]!
                .map((x) => ExecutionPlanNodeDesc.fromJson(x))),
        profiles: json["profiles"] == null
            ? []
            : List<ExecutionPlanNodeProfile>.from(json["profiles"]!
                .map((x) => ExecutionPlanNodeProfile.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "dependencies": dependencies == null
            ? []
            : List<dynamic>.from(dependencies!.map((x) => x)),
        "id": id,
        "name": name,
        "outputVar": outputVar,
        "description": description == null
            ? []
            : List<dynamic>.from(description!.map((x) => x.toJson())),
        "profiles": profiles == null
            ? []
            : List<dynamic>.from(profiles!.map((x) => x.toJson())),
      };
}

class ExecutionPlanNodeDesc {
  String? name;
  String? value;
  ExecutionPlanNodeDesc({this.name, this.value});

  factory ExecutionPlanNodeDesc.fromRawJson(String str) =>
      ExecutionPlanNodeDesc.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExecutionPlanNodeDesc.fromJson(Map<String, dynamic> json) =>
      ExecutionPlanNodeDesc(
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
      };
}

class ExecutionPlanNodeProfile {
  int? execDurationInUs;
  int? rows;
  int? totalDurationInUs;
  Map<String, String>? otherStats;

  ExecutionPlanNodeProfile({
    this.execDurationInUs,
    this.totalDurationInUs,
    this.rows,
    this.otherStats,
  });

  factory ExecutionPlanNodeProfile.fromRawJson(String str) =>
      ExecutionPlanNodeProfile.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ExecutionPlanNodeProfile.fromJson(Map<String, dynamic> json) =>
      ExecutionPlanNodeProfile(
        execDurationInUs: json["execDurationInUs"],
        totalDurationInUs: json["totalDurationInUs"],
        rows: json["rows"],
        otherStats: json["otherStats"]?.map<String, String>(
            (k, v) => MapEntry<String, String>('$k', '$v')),
      );

  Map<String, dynamic> toJson() => {
        "execDurationInUs": execDurationInUs,
        "totalDurationInUs": totalDurationInUs,
        "rows": rows,
        "otherStats": otherStats,
      };
}

extension ExecutionPlanNodeExt on ExecutionPlanNode {
  String get nameWithId => '${name}_$id';
  String get outputVarWithLabel => 'outputVar: $outputVar';
  String get inputVarWithLabel => 'inputVar: $inputVar';
}
