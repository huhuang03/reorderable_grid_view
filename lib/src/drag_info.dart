import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:reorderable_grid_view/src/reorderable_item.dart';

typedef _DragItemUpdate = void Function(
    DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(DragInfo item);

// Strange that you are create at onStart?
// It's boring that pass you so many params
class DragInfo extends Drag {
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

  DragInfo({
    required ReorderableItemViewState item,
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
          _scrollBeginTime = DateTime
              .now()
              .millisecondsSinceEpoch;
        }

        scroll = this.scrollSpeedController!(
          DateTime
              .now()
              .millisecondsSinceEpoch - _scrollBeginTime,
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
