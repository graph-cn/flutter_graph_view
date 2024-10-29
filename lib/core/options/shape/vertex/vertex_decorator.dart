// Copyright (c) 2024- All flutter_graph_view authors. All rights reserved.
//
// This source code is licensed under Apache 2.0 License.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_graph_view/flutter_graph_view.dart';

abstract class VertexDecorator {
  void decorate(
    Vertex vertex,
    ui.Canvas canvas,
    paint,
    paintLayers,
  );
}

class VertexImgDecorator extends VertexDecorator {
  @override
  void decorate(
    Vertex vertex,
    ui.Canvas canvas,
    paint,
    paintLayers,
  ) {
    var cpn = vertex.cpn!;
    var imgUrl = cpn.options?.imgUrlGetter.call(vertex);
    var img = getImg(imgUrl);
    if (img != null) {
      vertex.radius = 15;
      var imgRect = Rect.fromCircle(
        center: Offset(vertex.radiusZoom, vertex.radiusZoom),
        radius: vertex.radiusZoom - 1 / vertex.zoom,
      );
      final clipPath = ui.Path()
        ..addOval(Rect.fromCircle(
          center: imgRect.center,
          radius: vertex.radiusZoom - 1 / vertex.zoom,
        ));
      canvas.clipPath(clipPath);

      canvas.drawImageNine(
        img,
        imgRect,
        imgRect,
        paint,
      );
    }
  }

  ui.Image? getImg(String? img) {
    if (img == null) {
      return null;
    }

    if (imgCache.containsKey(img)) {
      return imgCache[img];
    } else {
      startTask(img);
      return null;
    }
  }

  startTask(String img) {
    if (tasks.contains(img)) {
      return;
    }
    tasks.add(img);
    var completer = Completer<ui.Image>();
    var task = completer.future;
    task.then((value) {
      imgCache[img] = value;
      tasks.remove(img);
    });
    NetworkAssetBundle(Uri.parse(img)).load(img).then((bd) async {
      imgCache[img] = await decodeImageFromList(Uint8List.view(bd.buffer));
    });
  }
}

var tasks = <String>[];
var imgCache = <String, ui.Image>{};
