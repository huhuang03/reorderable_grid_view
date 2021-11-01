import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../reorderable_grid_view.dart';
import 'package:flutter/widgets.dart';

import 'item.dart';

class ReorderableGridViewState extends State<ReorderableGridView>
    with TickerProviderStateMixin<ReorderableGridView> {
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

      if (index > widget.children.length - 1) {
        index = widget.children.length - 1;
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
        (itemWidth / (widget.childAspectRatio ?? 1.0) + widget.mainAxisSpacing);
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

    // recycle import!!
    final ReorderableGridItemState item = __items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();

    _dropIndex = _dragIndex;

    _dragInfo = _Drag(
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

  _onDragUpdate(_Drag item, Offset position, Offset delta) {
    updateDragTarget();
  }

  _onDragCancel(_Drag item) {
    _dragReset();
    setState(() {});
  }

  _onDragEnd(_Drag item) {
    widget.onReorder(_dragIndex!, _dropIndex!);
    _dragReset();
  }

  // ok, drag is end.
  _dragReset() {
    if (_dragIndex != null) {
      if (__items.containsKey(_dragIndex!)) {
        final ReorderableGridItemState item = __items[_dragIndex!]!;
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

  static ReorderableGridViewState of(BuildContext context) {
    return context.findAncestorStateOfType<ReorderableGridViewState>()!;
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
    var children = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      var child = widget.children[i];
      // children.add(child);
      children.add(ReorderableGridItem(
        child: child,
        key: child.key!,
        index: i,
        capturedThemes: InheritedTheme.capture(
            from: context, to: Overlay.of(context)!.context),
      ));
    }

    children.addAll(widget.footer ?? []);
    // why we can't use GridView? Because we can't handle the scroll event??
    // return Text("hello");
    return GridView.count(
      crossAxisCount: this.widget.crossAxisCount,
      children: children,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      cacheExtent: widget.cacheExtent,
      semanticChildCount: widget.semanticChildCount,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      mainAxisSpacing: widget.mainAxisSpacing,
      crossAxisSpacing: widget.crossAxisSpacing,
      childAspectRatio: widget.childAspectRatio ?? 1.0,
      addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
      addRepaintBoundaries: widget.addRepaintBoundaries,
      addSemanticIndexes: widget.addSemanticIndexes,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
    );
  }

  final Map<int, ReorderableGridItemState> __items = <int, ReorderableGridItemState>{};

  _Drag? _dragInfo;

  void registerItem(ReorderableGridItemState item) {
    __items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void unRegisterItem(int index, ReorderableGridItemState item) {
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

typedef _DragItemUpdate = void Function(
    _Drag item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_Drag item);


// Strange that you are create at onStart?
// It's boring that pass you so many params
class _Drag extends Drag {
  late int index;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onCancel;
  final _DragItemCallback? onEnd;
  final ScrollSpeedController? scrollSpeedController;

  final TickerProvider tickerProvider;
  final GestureMultiDragStartCallback onStart;

  final DragWidgetBuilder? dragWidgetBuilder;
  late Size itemSize;
  late Widget child;
  late ScrollableState scrollable;

  // Drag position always is the finger position in global
  Offset dragPosition;
  // dragOffset is the position finger pointer in local(renderObject's left top is (0, 0))
  // how to get the center of dragInfo in global.
  late Offset dragOffset;
  // = renderBox.size.height
  late double dragExtent;
  late Size dragSize;

  AnimationController? _proxyAnimationController;

  // Give to _Drag?? You want more control of the drag??
  OverlayEntry? _overlayEntry;
  BuildContext context;
  var hasEnd = false;

  _Drag({
    required ReorderableGridItemState item,
    required this.tickerProvider,
    required this.onStart,
    required this.dragPosition,
    required this.context,
    this.scrollSpeedController,
    this.dragWidgetBuilder,
    this.onUpdate,
    this.onCancel,
    this.onEnd,
  }) {
    index = item.index;
    child = item.widget.child;
    itemSize = item.context.size!;

    final RenderBox renderBox = item.context.findRenderObject()! as RenderBox;
    dragOffset = renderBox.globalToLocal(dragPosition);
    dragExtent = renderBox.size.height;
    dragSize = renderBox.size;

    scrollable = Scrollable.of(item.context)!;
  }

  Offset getCenterInGlobal() {
    return getPosInGlobal() + dragSize.center(Offset.zero);
  }

  Offset getPosInGlobal() {
    return this.dragPosition - this.dragOffset;
  }

  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    _proxyAnimationController?.dispose();
    _proxyAnimationController = null;
  }

  // why you need other calls?
  Widget createProxy(BuildContext context) {
    var position = this.dragPosition - this.dragOffset;
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: Container(
        width: itemSize.width,
        height: itemSize.height,
        child: dragWidgetBuilder != null
            ? dragWidgetBuilder!(index, child)
            : Material(
          elevation: 3.0,
          child: child,
        ),
      ),
    );
  }

  void startDrag() {
    _overlayEntry = OverlayEntry(builder: createProxy);
    // print("insert overlay");

    // Can you give the overlay to _Drag?
    final OverlayState overlay = Overlay.of(context)!;
    overlay.insert(_overlayEntry!);
    _scrollIfNeed();
  }

  @override
  void update(DragUpdateDetails details) {
    dragPosition += details.delta;
    onUpdate?.call(this, dragPosition, details.delta);

    _overlayEntry?.markNeedsBuild();
    _scrollIfNeed();
  }

  var _autoScrolling = false;

  var _scrollBeginTime = 0;

  static const _DEFAULT_SCROLL_DURATION = 14;

  void _scrollIfNeed() async {
    if (hasEnd) {
      _scrollBeginTime = 0;
      return;
    }
    if (hasEnd) return;

    if (!_autoScrolling) {
      double? newOffset;
      bool needScroll = false;
      final ScrollPosition position = scrollable.position;
      final RenderBox scrollRenderBox =
      scrollable.context.findRenderObject()! as RenderBox;

      final scrollOrigin = scrollRenderBox.localToGlobal(Offset.zero);
      final scrollStart = scrollOrigin.dy;

      final scrollEnd = scrollStart + scrollRenderBox.size.height;

      final dragInfoStart = getPosInGlobal().dy;
      final dragInfoEnd = dragInfoStart + dragExtent;

      // scroll bottom
      final overBottom = dragInfoEnd > scrollEnd;
      final overTop = dragInfoStart < scrollStart;

      final needScrollBottom =
          overBottom && position.pixels < position.maxScrollExtent;
      final needScrollTop =
          overTop && position.pixels > position.minScrollExtent;

      final double oneStepMax = 5;
      double scroll = oneStepMax;

      double overSize = 0;

      if (needScrollBottom) {
        overSize = dragInfoEnd - scrollEnd;
        scroll = min(overSize, oneStepMax);
      } else if (needScrollTop) {
        overSize = scrollStart - dragInfoStart;
        scroll = min(overSize, oneStepMax);
      }

      final calcOffset = () {
        if (needScrollBottom) {
          newOffset = min(position.maxScrollExtent, position.pixels + scroll);
        } else if (needScrollTop) {
          newOffset = max(position.minScrollExtent, position.pixels - scroll);
        }
        needScroll =
            newOffset != null && (newOffset! - position.pixels).abs() >= 1.0;
      };

      calcOffset();

      if (needScroll && this.scrollSpeedController != null) {
        if (_scrollBeginTime <= 0) {
          _scrollBeginTime = DateTime.now().millisecondsSinceEpoch;
        }

        scroll = this.scrollSpeedController!(
          DateTime.now().millisecondsSinceEpoch - _scrollBeginTime,
          overSize,
          itemSize.height,
        );

        calcOffset();
      }

      if (needScroll) {
        _autoScrolling = true;
        await position.animateTo(newOffset!,
            duration: Duration(milliseconds: _DEFAULT_SCROLL_DURATION),
            curve: Curves.linear);
        _autoScrolling = false;
        _scrollIfNeed();
      } else {
        // don't need scroll
        _scrollBeginTime = 0;
      }
    }
  }

  @override
  void end(DragEndDetails details) {
    // _debug("onDrag end");
    onEnd?.call(this);

    this._endOrCancel();
  }

  @override
  void cancel() {
    onCancel?.call(this);

    this._endOrCancel();
  }

  void _endOrCancel() {
    hasEnd = true;
  }
}
