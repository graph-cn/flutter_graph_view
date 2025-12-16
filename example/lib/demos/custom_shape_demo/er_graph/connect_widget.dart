// Copyright (c) 2025- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

// ignore_for_file: depend_on_referenced_packages

import 'dart:math';

import 'package:flutter/material.dart';

typedef AnchorConnectedCallback = void Function(
  AnchorType sourceAnchor,
  Offset sourcePosition,
  String targetId,
  AnchorType targetAnchor,
  Offset targetPosition,
);

typedef ConnectedCallback = Function(
    AnchorType sourceAnchor, String targetId, AnchorType targetAnchor);

/// 锚点类型枚举
enum AnchorType { top, right, bottom, left }

/// 连接数据模型
class Connection {
  final String sourceId;
  final AnchorType sourceAnchor;
  final Offset sourcePosition;
  final String targetId;
  final AnchorType targetAnchor;
  final Offset targetPosition;

  Connection({
    required this.sourceId,
    required this.sourceAnchor,
    required this.sourcePosition,
    required this.targetId,
    required this.targetAnchor,
    required this.targetPosition,
  });
}

/// 连接线绘制器
class ConnectionPainter extends CustomPainter {
  final Offset sourcePos;
  final Offset targetPos;

  ConnectionPainter({
    required this.sourcePos,
    required this.targetPos,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(sourcePos.dx, sourcePos.dy)
      ..cubicTo(
        sourcePos.dx + (targetPos.dx - sourcePos.dx) * 0.5,
        sourcePos.dy,
        sourcePos.dx + (targetPos.dx - sourcePos.dx) * 0.5,
        targetPos.dy,
        targetPos.dx,
        targetPos.dy,
      );

    canvas.drawPath(path, paint);

    // 绘制箭头
    final angle = (targetPos - sourcePos).direction;
    const arrowSize = 10.0;

    final arrowPath = Path()
      ..moveTo(targetPos.dx - arrowSize * cos(angle - pi / 6),
          targetPos.dy - arrowSize * sin(angle - pi / 6))
      ..lineTo(targetPos.dx, targetPos.dy)
      ..lineTo(targetPos.dx - arrowSize * cos(angle + pi / 6),
          targetPos.dy - arrowSize * sin(angle + pi / 6))
      ..close();

    canvas.drawPath(arrowPath, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 可连接组件封装
class ConnectableWidget extends StatefulWidget {
  final String id;
  final String title;
  final Color color;
  final double width;
  final double height;
  final AnchorConnectedCallback onAnchorConnected;

  const ConnectableWidget({
    super.key,
    this.id = 'default',
    required this.title,
    required this.color,
    this.width = 120,
    this.height = 80,
    required this.onAnchorConnected,
  });

  @override
  State<ConnectableWidget> createState() => _ConnectableWidgetState();
}

class _ConnectableWidgetState extends State<ConnectableWidget> {
  final Map<AnchorType, GlobalKey> anchorKeys = {
    AnchorType.top: GlobalKey(),
    AnchorType.right: GlobalKey(),
    AnchorType.bottom: GlobalKey(),
    AnchorType.left: GlobalKey(),
  };

  // 获取锚点的全局位置
  Offset getAnchorPosition(AnchorType type) {
    final key = anchorKeys[type];
    if (key?.currentContext == null) return Offset.zero;

    final renderBox = key?.currentContext?.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 组件内容
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'ID: ${widget.id}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          // 四个锚点
          Positioned(
            top: -10,
            left: widget.width / 2 - 10,
            child: AnchorPoint(
              key: anchorKeys[AnchorType.top],
              type: AnchorType.top,
              parentId: widget.id,
              onConnected: (sourceAnchor, targetId, targetAnchor) {
                widget.onAnchorConnected(
                  sourceAnchor,
                  getAnchorPosition(sourceAnchor),
                  targetId,
                  targetAnchor,
                  getAnchorPosition(targetAnchor),
                );
              },
            ),
          ),
          Positioned(
            top: widget.height / 2 - 10,
            right: -10,
            child: AnchorPoint(
              key: anchorKeys[AnchorType.right],
              type: AnchorType.right,
              parentId: widget.id,
              onConnected: (sourceAnchor, targetId, targetAnchor) {
                widget.onAnchorConnected(
                  sourceAnchor,
                  getAnchorPosition(sourceAnchor),
                  targetId,
                  targetAnchor,
                  getAnchorPosition(targetAnchor),
                );
              },
            ),
          ),
          Positioned(
            bottom: -10,
            left: widget.width / 2 - 10,
            child: AnchorPoint(
              key: anchorKeys[AnchorType.bottom],
              type: AnchorType.bottom,
              parentId: widget.id,
              onConnected: (sourceAnchor, targetId, targetAnchor) {
                widget.onAnchorConnected(
                  sourceAnchor,
                  getAnchorPosition(sourceAnchor),
                  targetId,
                  targetAnchor,
                  getAnchorPosition(targetAnchor),
                );
              },
            ),
          ),
          Positioned(
            top: widget.height / 2 - 10,
            left: -10,
            child: AnchorPoint(
              key: anchorKeys[AnchorType.left],
              type: AnchorType.left,
              parentId: widget.id,
              onConnected: (sourceAnchor, targetId, targetAnchor) {
                widget.onAnchorConnected(
                  sourceAnchor,
                  getAnchorPosition(sourceAnchor),
                  targetId,
                  targetAnchor,
                  getAnchorPosition(targetAnchor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个锚点组件
class AnchorPoint extends StatefulWidget {
  final AnchorType type;
  final String parentId;
  final ConnectedCallback onConnected;

  const AnchorPoint({
    super.key,
    required this.type,
    required this.parentId,
    required this.onConnected,
  });

  @override
  State<AnchorPoint> createState() => _AnchorPointState();
}

class _AnchorPointState extends State<AnchorPoint>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isConnected = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConnected(AnchorType targetAnchor, String targetId) {
    setState(() => _isConnected = true);
    _controller.forward(from: 0);
    widget.onConnected(widget.type, targetId, targetAnchor);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Draggable<Map<String, dynamic>>(
        data: {
          'sourceAnchor': widget.type,
          'parentId': widget.parentId,
        },
        feedback: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
        childWhenDragging: Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        onDragCompleted: () => setState(() => _isHovering = false),
        child: DragTarget<Map<String, dynamic>>(
          onWillAccept: (data) {
            return data != null &&
                data['sourceAnchor'] == widget.type &&
                data['parentId'] != widget.parentId;
          },
          onAccept: (data) {
            final sourceAnchor = data['sourceAnchor'] as AnchorType;
            final sourceParentId = data['parentId'] as String;
            _onConnected(sourceAnchor, sourceParentId);
          },
          builder: (context, candidateData, rejectedData) {
            return ScaleTransition(
              scale: _controller.drive(
                TweenSequence([
                  TweenSequenceItem(
                      tween: Tween(begin: 1.0, end: 1.5), weight: 1),
                  TweenSequenceItem(
                      tween: Tween(begin: 1.5, end: 1.0), weight: 1),
                ]),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _isConnected
                      ? Colors.green
                      : (_isHovering ? Colors.blue.shade400 : Colors.blue),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: _isHovering
                      ? [
                          BoxShadow(
                            color: Colors.blue.shade800.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ]
                      : null,
                ),
                child: candidateData.isNotEmpty
                    ? const Icon(Icons.link, size: 12, color: Colors.white)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
