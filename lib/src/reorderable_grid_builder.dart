import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'reorderable_item.dart';
import 'drag.dart';

class ReorderableGridBuilder extends StatefulWidget {
  const ReorderableGridBuilder({
    Key? key,
    required this.children,
    required this.gridDelegate,
    required this.addAutomaticKeepAlives,
    required this.addRepaintBoundaries,
    required this.addSemanticIndexes,
    this.onReorder,
  }) : super(key: key);

  final SliverGridDelegate gridDelegate;

  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final List<Widget> children;

  final ReorderCallback? onReorder;

  @override
  ReorderableGridBuilderState createState() => ReorderableGridBuilderState();
}

class ReorderableGridBuilderState extends State<ReorderableGridBuilder>
    with TickerProviderStateMixin<ReorderableGridBuilder> {
  late List<ReorderableGridItem> children;

  final Map<int, ReorderableGridItemState> _items = {};

  MultiDragGestureRecognizer? _recognizer;

  int? _dragIndex;
  int? _dropIndex;

  ReorderableDrag? _dragInfo;

  @override
  void initState() {
    super.initState();
    children = widget.children.map((child) {
      return ReorderableGridItem(
        key: GlobalKey(),
        child: child,
        index: widget.children.indexOf(child),
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: Overlay.of(context)!.context,
        ),
      );
    }).toList();
  }

  @override
  void didUpdateWidget(covariant ReorderableGridBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      children = widget.children.map((child) {
        return ReorderableGridItem(
          key: GlobalKey(),
          child: child,
          index: widget.children.indexOf(child),
          capturedThemes: InheritedTheme.capture(
            from: context,
            to: Overlay.of(context)!.context,
          ),
        );
      }).toList();
    });
  }

  void startDragRecognizer(
    int index,
    PointerDownEvent event,
    MultiDragGestureRecognizer recognizer,
  ) {
    setState(() {
      if (_dragIndex != null) dragReset();

      _dragIndex = index;
      _recognizer = recognizer
        ..onStart = _onDragStart
        ..addPointer(event);
    });
  }

  Offset getPos(int index) {
    index = index.clamp(0, children.length - 1);

    final key = children[index].key as GlobalKey;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return Offset.zero;

    final position = renderBox.localToGlobal(Offset.zero);
    return Offset(position.dx, position.dy);
  }

  int _calcDropIndex(int defaultIndex) {
    if (_dragInfo == null) return defaultIndex;

    for (var item in _items.values) {
      final box = item.context.findRenderObject() as RenderBox;

      final pos = box.globalToLocal(_dragInfo!.getCenterInGlobal());
      if (pos.dx > 0 &&
          pos.dy > 0 &&
          pos.dx < box.size.width &&
          pos.dy < box.size.height) {
        return item.index;
      }
    }
    return defaultIndex;
  }

  Offset getOffsetInDrag(int index) {
    if (_dragInfo == null || _dropIndex == null || _dragIndex == _dropIndex) {
      return Offset.zero;
    }

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

  Drag _onDragStart(Offset position) {
    assert(_dragInfo == null);

    final item = _items[_dragIndex!]!;

    item.dragging = true;
    item.rebuild();

    _dropIndex = _dragIndex;

    _dragInfo = ReorderableDrag(
      index: item.index,
      child: item.child,
      size: item.context.size!,
      context: item.context,
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

  _onDragUpdate(ReorderableDrag item, Offset position, Offset delta) {
    updateDragTarget();
  }

  _onDragCancel(ReorderableDrag item) => setState(dragReset);

  _onDragEnd(ReorderableDrag item) {
    widget.onReorder?.call(_dragIndex!, _dropIndex!);
    dragReset();
  }

  void dragReset() {
    if (_dragIndex != null) {
      if (_items.containsKey(_dragIndex!)) {
        final ReorderableGridItemState item = _items[_dragIndex!]!;
        item.dragging = false;
        item.rebuild();
      }

      _dragIndex = null;
      _dropIndex = null;

      for (var item in _items.values) {
        item.resetGap();
      }
    }

    _recognizer?.dispose();
    _recognizer = null;

    _dragInfo?.dispose();
    _dragInfo = null;
  }

  static ReorderableGridBuilderState of(BuildContext context) {
    return context.findAncestorStateOfType<ReorderableGridBuilderState>()!;
  }

  // Places the value from startIndex one space before the element at endIndex.
  void reorder(int startIndex, int endIndex) {
    // what to do??
    setState(() {
      if (startIndex != endIndex) widget.onReorder?.call(startIndex, endIndex);
      // Animates leftover space in the drop area closed.
    });
  }

  void registerItem(ReorderableGridItemState item) {
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void unRegisterItem(int index, ReorderableGridItemState item) {
    // why you check the item?
    var current = _items[index];
    if (current == item) {
      _items.remove(index);
    }
  }

  Future<void> updateDragTarget() async {
    int newTargetIndex = _calcDropIndex(_dropIndex!);
    if (newTargetIndex != _dropIndex) {
      _dropIndex = newTargetIndex;
      for (var item in _items.values) {
        item.updateForGap(_dropIndex!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildListDelegate(
        children,
        addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
        addRepaintBoundaries: widget.addRepaintBoundaries,
        addSemanticIndexes: widget.addSemanticIndexes,
      ),
      gridDelegate: widget.gridDelegate,
    );
  }
}
