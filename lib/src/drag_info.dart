import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:reorderable_grid_view/src/reorderable_item.dart';
import 'package:reorderable_grid_view/src/util.dart';

typedef DragItemUpdate = void Function(
    DragInfo item, Offset position, Offset delta);

typedef DragItemCallback = void Function(DragInfo item);

/// callback that draw widget ready build(most time take a screenshot)
typedef DragWidgetReadyCallback = void Function();

// Strange that you are create at onStart?
// It's boring that pass you so many params
class DragInfo extends Drag {
  late int index;
  final DragItemUpdate? onUpdate;
  final DragItemCallback? onCancel;
  final DragItemCallback? onEnd;
  final ScrollSpeedController? scrollSpeedController;
  final DragWidgetReadyCallback readyCallback;

  final TickerProvider tickerProvider;
  final GestureMultiDragStartCallback onStart;

  final DragWidgetBuilderV2? dragWidgetBuilder;
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
  // late GlobalKey screenshotKey;
  late ReorderableItemViewState item;

  AnimationController? _proxyAnimationController;

  // Give to _Drag?? You want more control of the drag??
  OverlayEntry? _overlayEntry;
  BuildContext context;
  OverlayState? overlay;
  var hasEnd = false;

  // zero pos in global, offset to navigation.
  // Fix issue #49
  Offset? zeroOffset;

  ImageProvider? dragWidgetScreenShot;

  DragInfo({
    required this.readyCallback,
    required this.item,
    required this.tickerProvider,
    required this.onStart,
    required this.dragPosition,
    required this.context,
    this.overlay,
    this.scrollSpeedController,
    this.dragWidgetBuilder,
    this.onUpdate,
    this.onCancel,
    this.onEnd,
  }) {
    index = item.index;
    child = item.widget.child;
    itemSize = item.context.size!;
    // screenshotKey = item.repaintKey;

    // why global to is is zero??
    zeroOffset = (_getOverlay().context.findRenderObject() as RenderBox).globalToLocal(Offset.zero);

    final RenderBox renderBox = item.context.findRenderObject()! as RenderBox;
    dragOffset = renderBox.globalToLocal(dragPosition);
    dragExtent = renderBox.size.height;
    dragSize = renderBox.size;

    // you can not delete !, because in some flutter version is option.
    scrollable = Scrollable.of(item.context)!;
  }

  NavigatorState? findNavigator(BuildContext context) {
    NavigatorState? navigator;
    if (context is StatefulElement && context.state is NavigatorState) {
      navigator = context.state as NavigatorState;
    }
    navigator = navigator ?? context.findAncestorStateOfType<NavigatorState>();
    return navigator;
  }

  Offset getCenterInGlobal() {
    return getPosInGlobal() + dragSize.center(Offset.zero);
  }

  Offset getPosInGlobal() {
    return dragPosition - dragOffset;
  }

  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    _proxyAnimationController?.dispose();
    _proxyAnimationController = null;
  }

  Widget createProxy(BuildContext context) {
    var position = dragPosition - dragOffset;
    if (zeroOffset != null) {
      position = position + zeroOffset!;
    }
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: SizedBox(
        width: itemSize.width,
        height: itemSize.height,
        child: dragWidgetBuilder != null
            ? dragWidgetBuilder!.builder(index, child, dragWidgetScreenShot)
            : Material(
                elevation: 3.0,
                child: _defaultDragWidget(context),
              ),
      ),
    );
  }

  Widget _defaultDragWidget(BuildContext context) {
    return child;
  }

  OverlayState _getOverlay() {
    // you can not delete !, because in some flutter version is option.
    return overlay?? Overlay.of(context)!;
  }

  void startDrag(ImageProvider? screenshot) {
    readyCallback();
    dragWidgetScreenShot = screenshot;
    _overlayEntry = OverlayEntry(builder: createProxy);

    // Can you give the overlay to _Drag?
    final OverlayState overlay = _getOverlay();
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

  static const defaultScrollDuration = 14;

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

      const double oneStepMax = 5;
      double scroll = oneStepMax;

      double overSize = 0;

      if (needScrollBottom) {
        overSize = dragInfoEnd - scrollEnd;
        scroll = min(overSize, oneStepMax);
      } else if (needScrollTop) {
        overSize = scrollStart - dragInfoStart;
        scroll = min(overSize, oneStepMax);
      }

      calcOffset() {
        if (needScrollBottom) {
          newOffset = min(position.maxScrollExtent, position.pixels + scroll);
        } else if (needScrollTop) {
          newOffset = max(position.minScrollExtent, position.pixels - scroll);
        }
        needScroll =
            newOffset != null && (newOffset! - position.pixels).abs() >= 1.0;
      }

      calcOffset();

      if (needScroll && scrollSpeedController != null) {
        if (_scrollBeginTime <= 0) {
          _scrollBeginTime = DateTime.now().millisecondsSinceEpoch;
        }

        scroll = scrollSpeedController!(
          DateTime.now().millisecondsSinceEpoch - _scrollBeginTime,
          overSize,
          itemSize.height,
        );

        calcOffset();
      }

      if (needScroll) {
        _autoScrolling = true;
        await position.animateTo(newOffset!,
            duration: const Duration(milliseconds: defaultScrollDuration),
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
    onEnd?.call(this);

    _endOrCancel();
  }

  @override
  void cancel() {
    onCancel?.call(this);

    _endOrCancel();
  }

  void _endOrCancel() {
    hasEnd = true;
  }
}

class ScreenshotWidget extends StatefulWidget {
  final RenderRepaintBoundary renderRepaintBoundary;
  final DragWidgetReadyCallback dragWidgetCallback;
  final double devicePixelRatio;

  const ScreenshotWidget({Key? key, required this.renderRepaintBoundary, required this.dragWidgetCallback, required this.devicePixelRatio}) : super(key: key);

  @override
  State<ScreenshotWidget> createState() => _ScreenshotWidgetState();
}

class _ScreenshotWidgetState extends State<ScreenshotWidget> {
  ImageProvider? imageProvider;

  _ScreenshotWidgetState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  _load() async {
    if (widget.renderRepaintBoundary.debugNeedsPaint) {
      Timer(const Duration(microseconds: 1), () => _load());
      return;
    }
    debug("devicePixelRatio: ${widget.devicePixelRatio}");
    var image = await widget.renderRepaintBoundary.toImage(pixelRatio: widget.devicePixelRatio);
    var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    widget.dragWidgetCallback();
    setState(() {
      if (byteData != null) {
        imageProvider = MemoryImage(Uint8List.view(byteData.buffer));
      } else {
        debug("why byteData is null?");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageProvider == null) {
      return Container();
    }
    return Image(image: imageProvider!);
  }
}


