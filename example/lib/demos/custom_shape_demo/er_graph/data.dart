// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'schema_vo.dart';

List<TableVo> tables = [
  // 地址表
  TableVo(
    name: 'address',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'areaId',
    properties: [
      PropertyVo(name: 'address_areaId', type: 'char', length: 6),
      PropertyVo(name: 'address_name', type: 'varchar', length: 50),
      PropertyVo(name: 'address_regionId', type: 'char', length: 6),
    ],
  ),

  // 管理员表
  TableVo(
    name: 'admin',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'admin_id',
    properties: [
      PropertyVo(name: 'admin_id', type: 'int'),
      PropertyVo(name: 'admin_name', type: 'varchar', length: 25),
      PropertyVo(name: 'admin_password', type: 'varchar', length: 50),
      PropertyVo(name: 'admin_nickname', type: 'varchar', length: 20),
      PropertyVo(
          name: 'admin_profile_picture_src', type: 'varchar', length: 100),
    ],
  ),

  // 分类表
  TableVo(
    name: 'category',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'category_id',
    properties: [
      PropertyVo(name: 'category_id', type: 'int'),
      PropertyVo(name: 'category_name', type: 'varchar', length: 20),
      PropertyVo(name: 'category_image_src', type: 'varchar', length: 255),
    ],
  ),

  // 产品表
  TableVo(
    name: 'product',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'product_id',
    properties: [
      PropertyVo(name: 'product_id', type: 'int'),
      PropertyVo(name: 'product_name', type: 'varchar', length: 100),
      PropertyVo(name: 'product_title', type: 'varchar', length: 100),
      PropertyVo(
          name: 'product_price', type: 'decimal', length: 10, comment: '价格'),
      PropertyVo(
          name: 'product_sale_price',
          type: 'decimal',
          length: 10,
          comment: '促销价格'),
      PropertyVo(name: 'product_create_date', type: 'datetime'),
      PropertyVo(name: 'product_category_id', type: 'int'),
      PropertyVo(name: 'product_isEnabled', type: 'tinyint'),
      PropertyVo(name: 'product_sale_count', type: 'int'),
      PropertyVo(name: 'product_review_count', type: 'int'),
    ],
  ),

  // 商品图片表
//   productimage_id	int	0	0	0	-1	0	0	0		0					-1	0
// productimage_type	tinyint	0	0	0	0	-1	0	0		0					0	0
// productimage_src	varchar	255	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productimage_product_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'productimage',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'productimage_id',
    properties: [
      PropertyVo(name: 'productimage_id', type: 'int'),
      PropertyVo(name: 'productimage_type', type: 'tinyint'),
      PropertyVo(name: 'productimage_src', type: 'varchar', length: 255),
      PropertyVo(name: 'productimage_product_id', type: 'int'),
    ],
  ),
  // 订单表
//   productorder_id	int	0	0	0	-1	0	0	0		0					-1	0
// productorder_code	varchar	30	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_address	char	6	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_detail_address	varchar	255	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_post	char	6	0	-1	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_receiver	varchar	20	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_mobile	char	11	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// productorder_pay_date	datetime	0	0	0	0	0	0	0		0					0	0
// productorder_delivery_date	datetime	0	0	-1	0	0	0	0		0					0	0
// productorder_confirm_date	datetime	0	0	-1	0	0	0	0		0					0	0
// productorder_status	tinyint	1	0	0	0	0	0	0		0					0	0
// productorder_user_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'productorder',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'productorder_id',
    properties: [
      PropertyVo(name: 'productorder_id', type: 'int'),
      PropertyVo(name: 'productorder_code', type: 'varchar', length: 30),
      PropertyVo(name: 'productorder_address', type: 'char', length: 6),
      PropertyVo(
          name: 'productorder_detail_address', type: 'varchar', length: 255),
      PropertyVo(name: 'productorder_post', type: 'char', length: 6),
      PropertyVo(name: 'productorder_receiver', type: 'varchar', length: 20),
      PropertyVo(name: 'productorder_mobile', type: 'char', length: 11),
      PropertyVo(name: 'productorder_pay_date', type: 'datetime'),
      PropertyVo(name: 'productorder_delivery_date', type: 'datetime'),
      PropertyVo(name: 'productorder_confirm_date', type: 'datetime'),
      PropertyVo(name: 'productorder_status', type: 'tinyint'),
      PropertyVo(name: 'productorder_user_id', type: 'int'),
    ],
  ),

// productorderitem_id	int	0	0	0	-1	0	0	0		0					-1	0
// productorderitem_number	smallint	0	0	0	0	-1	0	0		0					0	0
// productorderitem_price	decimal	10	2	0	0	0	0	0		0					0	0
// productorderitem_product_id	int	0	0	0	0	0	0	0		0					0	0
// productorderitem_order_id	int	0	0	-1	0	0	0	0		0					0	0
// productorderitem_user_id	int	0	0	0	0	0	0	0		0					0	0
// productorderitem_userMessage	varchar	255	0	-1	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
  TableVo(
    name: 'productorderitem',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'productorderitem_id',
    properties: [
      PropertyVo(name: 'productorderitem_id', type: 'int'),
      PropertyVo(name: 'productorderitem_number', type: 'smallint'),
      PropertyVo(name: 'productorderitem_price', type: 'decimal', length: 10),
      PropertyVo(name: 'productorderitem_product_id', type: 'int'),
      PropertyVo(name: 'productorderitem_order_id', type: 'int'),
      PropertyVo(name: 'productorderitem_user_id', type: 'int'),
      PropertyVo(
          name: 'productorderitem_userMessage', type: 'varchar', length: 255),
    ],
  ),

// property_id	int	0	0	0	-1	0	0	0		0					-1	0
// property_name	varchar	25	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// property_category_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'property',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'property_id',
    properties: [
      PropertyVo(name: 'property_id', type: 'int'),
      PropertyVo(name: 'property_name', type: 'varchar', length: 25),
      PropertyVo(name: 'property_category_id', type: 'int'),
    ],
  ),

// propertyvalue_id	int	0	0	0	-1	0	0	0		0					-1	0
// propertyvalue_value	varchar	100	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// propertyvalue_property_id	int	0	0	0	0	0	0	0		0					0	0
// propertyvalue_product_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'propertyvalue',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'propertyvalue_id',
    properties: [
      PropertyVo(name: 'propertyvalue_id', type: 'int'),
      PropertyVo(name: 'propertyvalue_value', type: 'varchar', length: 100),
      PropertyVo(name: 'propertyvalue_property_id', type: 'int'),
      PropertyVo(name: 'propertyvalue_product_id', type: 'int'),
    ],
  ),

// review_id	int	0	0	0	-1	0	0	0		0					-1	0
// review_content	mediumtext	0	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// review_createdate	datetime	0	0	0	0	0	0	0		0					0	0
// review_user_id	int	0	0	0	0	0	0	0		0					0	0
// review_product_id	int	0	0	0	0	0	0	0		0					0	0
// review_orderItem_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'review',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'review_id',
    properties: [
      PropertyVo(name: 'review_id', type: 'int'),
      PropertyVo(name: 'review_content', type: 'mediumtext'),
      PropertyVo(name: 'review_createdate', type: 'datetime'),
      PropertyVo(name: 'review_user_id', type: 'int'),
      PropertyVo(name: 'review_product_id', type: 'int'),
      PropertyVo(name: 'review_orderItem_id', type: 'int'),
    ],
  ),

// reward_id	int	0	0	0	-1	0	0	0		0					-1	0
// reward_name	varchar	50	0	0	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// reward_content	varchar	255	0	-1	0	0	0	0		0		utf8mb3	utf8mb3_general_ci		0	0
// reward_createDate	datetime	0	0	0	0	0	0	0		0					0	0
// reward_state	int	0	0	0	0	0	0	0		0					0	0
// reward_amount	decimal	10	2	0	0	0	0	0		0					0	0
// reward_user_id	int	0	0	0	0	0	0	0		0					0	0
  TableVo(
    name: 'reward',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'reward_id',
    properties: [
      PropertyVo(name: 'reward_id', type: 'int'),
      PropertyVo(name: 'reward_name', type: 'varchar', length: 50),
      PropertyVo(name: 'reward_content', type: 'varchar', length: 255),
      PropertyVo(name: 'reward_createDate', type: 'datetime'),
      PropertyVo(name: 'reward_state', type: 'int'),
      PropertyVo(name: 'reward_amount', type: 'decimal', length: 10),
      PropertyVo(name: 'reward_user_id', type: 'int'),
    ],
  ),

  // 用户表
  TableVo(
    name: 'user',
    db: DbVo(name: 'tmalldemodb'),
    primary: 'user_id',
    properties: [
      PropertyVo(name: 'user_id', type: 'int'),
      PropertyVo(name: 'user_name', type: 'varchar', length: 25),
      PropertyVo(name: 'user_nickname', type: 'varchar', length: 50),
      PropertyVo(name: 'user_password', type: 'varchar', length: 50),
      PropertyVo(name: 'user_realname', type: 'varchar', length: 20),
      PropertyVo(name: 'user_gender', type: 'tinyint'),
      PropertyVo(name: 'user_birthday', type: 'date'),
      PropertyVo(name: 'user_address', type: 'char', length: 6),
      PropertyVo(name: 'user_homeplace', type: 'char', length: 6),
      PropertyVo(
          name: 'user_profile_picture_src', type: 'varchar', length: 100),
    ],
  ),
];

List<Constants> constants = [
  Constants(
    schema: 'tmalldemodb',
    name: 'address_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'address',
    columnName: 'address_regionId',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'address',
    referencedColumnName: 'address_areaId',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'product_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'product',
    columnName: 'product_category_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'category',
    referencedColumnName: 'category_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productimage_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'productimage',
    columnName: 'productimage_product_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'product',
    referencedColumnName: 'product_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productorder_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'productorder',
    columnName: 'productorder_address',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'address',
    referencedColumnName: 'address_areaId',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productorder_ibfk_2',
    tableSchema: 'tmalldemodb',
    tableName: 'productorder',
    columnName: 'productorder_user_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'user',
    referencedColumnName: 'user_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productorderitem_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'productorderitem',
    columnName: 'productorderitem_product_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'product',
    referencedColumnName: 'product_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productorderitem_ibfk_2',
    tableSchema: 'tmalldemodb',
    tableName: 'productorderitem',
    columnName: 'productorderitem_order_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'productorder',
    referencedColumnName: 'productorder_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'productorderitem_ibfk_3',
    tableSchema: 'tmalldemodb',
    tableName: 'productorderitem',
    columnName: 'productorderitem_user_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'user',
    referencedColumnName: 'user_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'property_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'property',
    columnName: 'property_category_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'category',
    referencedColumnName: 'category_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'propertyvalue_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'propertyvalue',
    columnName: 'propertyvalue_property_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'property',
    referencedColumnName: 'property_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'propertyvalue_ibfk_2',
    tableSchema: 'tmalldemodb',
    tableName: 'propertyvalue',
    columnName: 'propertyvalue_product_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'product',
    referencedColumnName: 'product_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'review_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'review',
    columnName: 'review_user_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'user',
    referencedColumnName: 'user_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'review_ibfk_2',
    tableSchema: 'tmalldemodb',
    tableName: 'review',
    columnName: 'review_product_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'product',
    referencedColumnName: 'product_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'review_ibfk_3',
    tableSchema: 'tmalldemodb',
    tableName: 'review',
    columnName: 'review_orderItem_id',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'productorderitem',
    referencedColumnName: 'productorderitem_id',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'user_ibfk_1',
    tableSchema: 'tmalldemodb',
    tableName: 'user',
    columnName: 'user_address',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'address',
    referencedColumnName: 'address_areaId',
  ),
  Constants(
    schema: 'tmalldemodb',
    name: 'user_ibfk_2',
    tableSchema: 'tmalldemodb',
    tableName: 'user',
    columnName: 'user_homeplace',
    referencedTableSchema: 'tmalldemodb',
    referencedTableName: 'address',
    referencedColumnName: 'address_areaId',
  ),
];
