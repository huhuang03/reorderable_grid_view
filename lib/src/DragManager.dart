import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Can I have an state??
class DragManager {
  MultiDragGestureRecognizer? _recognizer;
  late State _state;

  DragManager();

  setState(State state) {
    this._state = state;
  }

}