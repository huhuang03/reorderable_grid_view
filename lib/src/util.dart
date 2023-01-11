import 'dart:ui' as ui show Image;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

const _IS_DEBUG = false;

debug(String msg) {
  if (_IS_DEBUG) {
    print("ReorderableGridView: $msg");
  }
}


Future<ui.Image?> takeScreenShot(State state) async {
  var renderObject = state.context.findRenderObject();
  // var renderObject = item.context.findRenderObject();
  if (renderObject is RenderRepaintBoundary) {
    RenderRepaintBoundary renderRepaintBoundary = renderObject;
    // not good at here
    var devicePixelRatio = MediaQuery.of(state.context).devicePixelRatio;
    return renderRepaintBoundary.toImage(pixelRatio: devicePixelRatio);
  }
}