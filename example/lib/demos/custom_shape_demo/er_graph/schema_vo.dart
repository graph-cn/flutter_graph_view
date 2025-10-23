// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

class TableVo {
  String? primary;
  PropertyVo? primaryProp;
  DbVo? db;
  String name;
  String? comment;
  List<PropertyVo> properties;
  TableVo({
    required this.db,
    required this.name,
    required this.properties,
    this.comment,
    this.primary,
  });
}

class DbVo {
  String? name;
  DbVo({
    this.name,
  });
}

class PropertyVo {
  String name;
  String type;
  int? length;
  String? comment;

  PropertyVo({
    required this.name,
    required this.type,
    this.length,
    this.comment,
  });
}

class Constants {
  String schema;
  String name;
  String tableSchema;
  String tableName;
  String columnName;
  String referencedTableSchema;
  String referencedTableName;
  String referencedColumnName;
  bool isVirtual;

  Constants({
    required this.schema,
    required this.name,
    required this.tableSchema,
    required this.tableName,
    required this.columnName,
    required this.referencedTableSchema,
    required this.referencedTableName,
    required this.referencedColumnName,
    this.isVirtual = false,
  });
}
