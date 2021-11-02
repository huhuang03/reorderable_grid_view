import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/reorderable_item.dart';

import '../reorderable_grid_view.dart';
import 'drag_info.dart';

mixin ReorderableGridWidgetMixin on StatefulWidget {
  int get crossAxisCount;
  double get mainAxisSpacing;
  double get crossAxisSpacing;
  double get childAspectRatio;

  ReorderCallback get onReorder;
  DragWidgetBuilder? get dragWidgetBuilder;
  ScrollSpeedController? get scrollSpeedController;

  Widget get child;
}

// What I want is I can call setState and get those properties.
// So I want my widget to on The ReorderableGridWidgetMixin
mixin ReorderableGridStateMixin<T extends ReorderableGridWidgetMixin> on State<T>, TickerProviderStateMixin<T> {
  MultiDragGestureRecognizer? _recognizer;

  // it's not as drag start?
  void startDragRecognizer(int index, PointerDownEvent event,
      MultiDragGestureRecognizer recognizer) {
    // how to fix enter this twice?
    setState(() {
      if (_dragIndex != null) {
        _dragReset();
      }

      _dragIndex = index;
      _recognizer = recognizer
        ..onStart = _onDragStart
        ..addPointer(event);
    });
  }

  int? _dragIndex;

  int? _dropIndex;

  // how to return row, col?

  // The pos is relate to the container's 0, 0
  Offset getPos(int index, {bool safe = true}) {
    if (safe) {
      if (index < 0) {
        index = 0;
      }
    }

    RenderBox? renderBox = this.context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return Offset.zero;
    }

    double itemWidth = (renderBox.size.width -
        (widget.crossAxisCount - 1) * widget.crossAxisSpacing) /
        widget.crossAxisCount;

    int row = index ~/ widget.crossAxisCount;
    int col = index % widget.crossAxisCount;

    double x = (col - 1) * (itemWidth + widget.crossAxisSpacing);
    double y = (row - 1) *
        (itemWidth / (widget.childAspectRatio) + widget.mainAxisSpacing);
    return Offset(x, y);
  }

  // Ok, let's no calc the dropIndex
  // Check the dragInfo before you call this function.
  int _calcDropIndex(int defaultIndex) {
    // _debug("_calcDropIndex");

    if (_dragInfo == null) {
      // _debug("_dragInfo is null, so return: $defaultIndex");
      return defaultIndex;
    }

    for (var item in __items.values) {
      RenderBox box = item.context.findRenderObject() as RenderBox;
      Offset pos = box.globalToLocal(_dragInfo!.getCenterInGlobal());
      if (pos.dx > 0 &&
          pos.dy > 0 &&
          pos.dx < box.size.width &&
          pos.dy < box.size.height) {
        // _debug("return item.index: ${item.index}");
        return item.index;
      }
    }
    return defaultIndex;
  }

  Offset getOffsetInDrag(int index) {
    if (_dragInfo == null || _dropIndex == null || _dragIndex == _dropIndex) {
      return Offset.zero;
    }

    // ok now we check.
    bool inDragRange = false;
    bool isMoveLeft = _dropIndex! > _dragIndex!;

    int minPos = min(_dragIndex!, _dropIndex!);
    int maxPos = max(_dragIndex!, _dropIndex!);

    if (index >= minPos && index <= maxPos) {
      inDragRange = true;
    }

    if (!inDragRange) {
      return Offset.zero;
    } else {
      if (isMoveLeft) {
        return getPos(index - 1) - getPos(index);
      } else {
        return getPos(index + 1) - getPos(index);
      }
    }
  }

  // position is the global position
  Drag _onDragStart(Offset position) {
    // print("drag start!!, _dragIndex: $_dragIndex, position: ${position}");
    assert(_dragInfo == null);

    final ReorderableItemViewState item = __items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();

    _dropIndex = _dragIndex;

    _dragInfo = DragInfo(
      item: item,
      tickerProvider: this,
      context: context,
      dragWidgetBuilder: this.widget.dragWidgetBuilder,
      scrollSpeedController: this.widget.scrollSpeedController,
      onStart: _onDragStart,
      dragPosition: position,
      onUpdate: _onDragUpdate,
      onCancel: _onDragCancel,
      onEnd: _onDragEnd,
    );
    _dragInfo!.startDrag();
    updateDragTarget();

    return _dragInfo!;
  }

  _onDragUpdate(DragInfo item, Offset position, Offset delta) {
    updateDragTarget();
  }

  _onDragCancel(DragInfo item) {
    _dragReset();
    setState(() {});
  }

  _onDragEnd(DragInfo item) {
    widget.onReorder(_dragIndex!, _dropIndex!);
    _dragReset();
  }

  // ok, drag is end.
  _dragReset() {
    if (_dragIndex != null) {
      if (__items.containsKey(_dragIndex!)) {
        final ReorderableItemViewState item = __items[_dragIndex!]!;
        item.dragging = false;
        item.rebuild();
      }

      _dragIndex = null;
      _dropIndex = null;

      for (var item in __items.values) {
        item.resetGap();
      }
    }

    _recognizer?.dispose();
    _recognizer = null;

    _dragInfo?.dispose();
    _dragInfo = null;
  }

  // stock at here.
  static ReorderableGridStateMixin of(BuildContext context) {
    return context.findAncestorStateOfType<ReorderableGridStateMixin>()!;
  }

  // Places the value from startIndex one space before the element at endIndex.
  void reorder(int startIndex, int endIndex) {
    // what to do??
    setState(() {
      if (startIndex != endIndex) widget.onReorder(startIndex, endIndex);
      // Animates leftover space in the drop area closed.
    });
  }

  @override
  Widget build(BuildContext context) {
    // create the draggable item in build function?
    // return Text("hello");
    // ok, how to replace the child??
    return widget.child;
  }

  final Map<int, ReorderableItemViewState> __items =
  <int, ReorderableItemViewState>{};

  DragInfo? _dragInfo;

  void registerItem(ReorderableItemViewState item) {
    __items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void unRegisterItem(int index, ReorderableItemViewState item) {
    // why you check the item?
    var current = __items[index];
    if (current == item) {
      __items.remove(index);
    }
  }

  Future<void> updateDragTarget() async {
    int newTargetIndex = _calcDropIndex(_dropIndex!);
    if (newTargetIndex != _dropIndex) {
      _dropIndex = newTargetIndex;
      for (var item in __items.values) {
        item.updateForGap(_dropIndex!);
      }
    }
  }
}