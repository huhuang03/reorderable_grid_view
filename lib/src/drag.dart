import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'typedefs.dart';

class ReorderableDrag extends Drag {
  ReorderableDrag({
    required this.context,
    required this.index,
    required this.child,
    required this.size,
    required this.onStart,
    required this.dragPosition,
    this.dragWidgetBuilder,
    this.onUpdate,
    this.onCancel,
    this.onEnd,
  }) {
    
    final RenderBox renderBox = context.findRenderObject()! as RenderBox;
    dragOffset = renderBox.globalToLocal(dragPosition);
    dragExtent = renderBox.size.height;
    dragSize = renderBox.size;

    scrollable = Scrollable.of(context)!;
  }

  final BuildContext context;
  final int index;
  final Widget child;
  final Size size;
  final GestureMultiDragStartCallback onStart;
  Offset dragPosition;

  final DragWidgetBuilder? dragWidgetBuilder;
  final DragItemUpdate? onUpdate;
  final DragItemCallback? onCancel;
  final DragItemCallback? onEnd;


  late ScrollableState scrollable;

  late Offset dragOffset;
  late double dragExtent;
  late Size dragSize;

  OverlayEntry? _overlayEntry;

  bool hasEnd = false;
  bool _autoScrolling = false;

  Offset getCenterInGlobal() {
    return getPosInGlobal() + dragSize.center(Offset.zero);
  }

  Offset getPosInGlobal() {
    return dragPosition - dragOffset;
  }

  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }



  Widget createProxy(BuildContext context) {
    var position = getPosInGlobal();

    return Positioned(
      top: position.dy,
      left: position.dx,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: dragWidgetBuilder != null
            ? dragWidgetBuilder!(index, child)
            : Material(elevation: 3.0, child: child),
      ),
    );
  }

  void startDrag() {
    _overlayEntry = OverlayEntry(builder: createProxy);
    // print("insert overlay");

    // Can you give the overlay to ReorderableDrag?
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

  void _scrollIfNeed() async {
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

      const oneStepMax = 5.0;

      void calcOffset() {
        if (needScrollBottom) {
          newOffset =
              min(position.maxScrollExtent, position.pixels + oneStepMax);
        } else if (needScrollTop) {
          newOffset =
              max(position.minScrollExtent, position.pixels - oneStepMax);
        }
        needScroll =
            newOffset != null && (newOffset! - position.pixels).abs() >= 1.0;
      }

      calcOffset();

      if (!needScroll) return;

      _autoScrolling = true;

      await position.animateTo(
        newOffset!,
        duration: const Duration(milliseconds: 14),
        curve: Curves.linear,
      );

      _autoScrolling = false;
      _scrollIfNeed();
    }
  }

  @override
  void end(DragEndDetails details) {
    onEnd?.call(this);
    hasEnd = true;
  }

  @override
  void cancel() {
    onCancel?.call(this);
    hasEnd = true;
  }
}
