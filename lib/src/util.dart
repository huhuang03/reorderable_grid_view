import 'dart:ui' as ui show Image;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

const isDebug = false;

debug(String msg) {
  if (isDebug) {
    debugPrint("ReorderableGridView: $msg");
  }
}


Future<ui.Image?> takeScreenShot(State state) async {
  var renderObject = state.context.findRenderObject();
  // var renderObject = item.context.findRenderObject();
  if (renderObject is RenderRepaintBoundary) {
    RenderRepaintBoundary renderRepaintBoundary = renderObject;
    var devicePixelRatio = MediaQuery.of(state.context).devicePixelRatio;
    await Future.delayed(Duration.zero);
    return renderRepaintBoundary.toImage(pixelRatio: devicePixelRatio);
  }
  return null;
}