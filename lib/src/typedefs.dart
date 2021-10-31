import 'package:flutter/widgets.dart';
import 'drag.dart';

typedef DragManagerItemUpdate = void Function(
    ReorderableDrag item, Offset position, Offset delta);

typedef DragManagerItemCallback = void Function(ReorderableDrag item);

typedef DragWidgetBuilder = Widget Function(int index, Widget child);


typedef DragItemUpdate = void Function(
    ReorderableDrag item, Offset position, Offset delta);
typedef DragItemCallback = void Function(ReorderableDrag item);
