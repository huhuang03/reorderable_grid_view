import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Usage:
/// ```
/// ReorderableGridView(
///   crossAxisCount: 3,
///   children: this.data.map((e) => buildItem("$e")).toList(),
///   onReorder: (oldIndex, newIndex) {
///     setState(() {
///       final element = data.removeAt(oldIndex);
///       data.insert(newIndex, element);
///     });
///   },
/// )
///```
class ReorderableGridView extends StatefulWidget {
  final List<Widget> children;
  final List<Widget>? footer;
  final int crossAxisCount;
  final ReorderCallback onReorder;
  final bool? primary;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool reverse;
  final double? cacheExtent;
  final int? semanticChildCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final addSemanticIndexes;

  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;
  final String? restorationId;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// I think anti multi drag is loss performance.
  /// So default is false, and only set if you care this case.
  final bool antiMultiDrag;

  ReorderableGridView(
    {
      Key? key,
      required this.children,
      this.clipBehavior = Clip.hardEdge,
      this.cacheExtent,
      this.semanticChildCount,
      this.keyboardDismissBehavior  = ScrollViewKeyboardDismissBehavior.manual,
      this.restorationId,
      this.reverse = false,
      required this.crossAxisCount,
      this.padding,
      required this.onReorder,
      this.physics,
      this.footer,
      this.primary,
      this.mainAxisSpacing = 0.0,
      this.crossAxisSpacing = 0.0,
      this.childAspectRatio = 1.0,
      this.addAutomaticKeepAlives = true,
      this.addRepaintBoundaries = true,
      this.addSemanticIndexes = true,
      this.shrinkWrap = true,
      this.antiMultiDrag = false,
    })
    : super(key: key);

  @override
  _ReorderableGridViewState createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView>
    with TickerProviderStateMixin<ReorderableGridView> {


  MultiDragGestureRecognizer? _recognizer;

  void startDragRecognizer(int index, PointerDownEvent event, MultiDragGestureRecognizer<MultiDragPointerState> recognizer) {
    _dragIndex = index;
    _recognizer = recognizer
        ..onStart = _onDragStart
        ..addPointer(event);
  }

  int? _dragIndex;

  // position is the global position
  Drag _onDragStart(Offset position) {
    // print("drag start!!, _dragIndex: $_dragIndex, position: ${position}");
    // how can you do this?
    assert(_dragInfo == null);

    final _ReorderableGridItemState item = __items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();


    _dragInfo = _Drag(
        item: item,
        tickerProvider: this,
        context: context,
        onStart: _onDragStart,
        dragPosition: position,
        onUpdate: _onDragUpdate,
        onCancel: _onDragCancel,
        onEnd: _onDragEnd,
    );
    _dragInfo!.startDrag();

    return _dragInfo!;
  }

  _onDragUpdate(_Drag item, Offset position, Offset delta) {
  }

  _onDragCancel(_Drag item) {
    _dragReset();
    setState(() {

    });
  }

  _onDragEnd(_Drag item) {
    _dragReset();
    setState(() {

    });
  }

  _dragReset() {
    if (_dragIndex != null)  {
      final _ReorderableGridItemState item = __items[_dragIndex!]!;
      _dragIndex = null;
      item.dragging = false;
      item.rebuild();
      _dragIndex = null;
    }
    _dragInfo = null;
  }

  static _ReorderableGridViewState of(BuildContext context) {
    return context.findAncestorStateOfType<_ReorderableGridViewState>()!;
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
      children.add(_ReorderableGridItem(child: child,
        key: child.key!,
        index: i,
        capturedThemes: InheritedTheme.capture(from: context, to: Overlay.of(context)!.context),));
    }

    children.addAll(widget.footer?? []);
    // why we can't use GridView? Because we can't handle the scroll event??
    // return Text("hello");
    return GridView.count(
      crossAxisCount: this.widget.crossAxisCount,
      children: children,
    );
    // return GridView(gridDelegate: gridDelegate);
    return CustomScrollView(
      // slivers: children,
    );

  }

  final Map<int, _ReorderableGridItemState> __items = <int, _ReorderableGridItemState>{};

  _Drag? _dragInfo;

  void _registerItem(_ReorderableGridItemState item) {
    __items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unRegisterItem(int index, _ReorderableGridItemState item) {
    // why you check the item?
    var current = __items[index];
    if (current == item) {
      __items.remove(index);
    }
  }
}

const _IS_DEBUG = true;

_debug(String msg) {
  if (_IS_DEBUG) {
    print("ReorderableGridView: " + msg);
  }
}

class _ReorderableGridItem extends StatefulWidget {
  final Widget child;
  final Key key;
  final int index;
  final CapturedThemes capturedThemes;

  const _ReorderableGridItem({
    required this.child,
    required this.key,
    required this.index,
    required this.capturedThemes
  }): super(key: key);

  @override
  _ReorderableGridItemState createState() => _ReorderableGridItemState();
}

class _ReorderableGridItemState extends State<_ReorderableGridItem> with TickerProviderStateMixin {
  late _ReorderableGridViewState _listState;

  Key get key => widget.key;
  Widget get child => widget.child;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      this.setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  // Ok, for now we use multiDragRecognizer
  MultiDragGestureRecognizer<MultiDragPointerState> _createDragRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }

  @override
  void initState() {
    _listState = _ReorderableGridViewState.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _animationController;

  Offset get offset {
    // why you can erase?? not the pointer under the finger??
    if (_animationController != null) {
      return Offset.lerp(_startOffset, _targetOffset, Curves.easeInOut.transform(_animationController!.value))!;
    }
    return _targetOffset;
  }

  @override
  void dispose() {
    _listState._unRegisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ReorderableGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unRegisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildChild(Widget child) {
      // why you register at here?
      // print("build called with at ${index}, _dragging: ${_dragging}");
      return LayoutBuilder(builder: (context, constraints) {
        if (_dragging) {
          // why put you in the Listener??
          return SizedBox();
        }
        var _offset = offset;
        return Transform(
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: child,
        );
      },);
    }

    return Listener(
      onPointerDown: (PointerDownEvent e) {
           // remember th pointer down??
        _debug("onPointerDown at $index");
        var listState = _ReorderableGridViewState.of(context);
        listState.startDragRecognizer(index, e, _createDragRecognizer());
      },
      child: _buildChild(child),
    );
  }

  void rebuild() {
    print("rebuild called for index: ${this.index}, mounted: ${mounted}");
    if (mounted) {
      setState(() {});
    }
  }
}

typedef _DragItemUpdate = void Function(_Drag item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_Drag item);

// OnStart give to you?
// Strange that you are create at onStart?
class _Drag extends Drag {
  late int index;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onCancel;
  final _DragItemCallback? onEnd;

  final TickerProvider tickerProvider;
  final GestureMultiDragStartCallback onStart;

  late Size itemSize;
  late Widget child;

  // Drag position always is the finger position in global
  Offset dragPosition;
  late Offset dragOffset;

  late CapturedThemes _capturedThemes;
  AnimationController? _proxyAnimationController;

  // Give to _Drag?? You want more control of the drag??
  OverlayEntry? _overlayEntry;
  BuildContext context;

  _Drag({
    required _ReorderableGridItemState item,
    required this.tickerProvider,
    required this.onStart,
    required this.dragPosition,
    required this.context,
    this.onUpdate,
    this.onCancel,
    this.onEnd,
  }) {
    index = item.index;
    child = item.widget.child;
    itemSize = item.context.size!;
    _capturedThemes = item.widget.capturedThemes;
    final RenderBox itemRenderBox = item.context.findRenderObject()! as RenderBox;
    // 为什么是>?
    // 注意这里是反
    dragOffset = itemRenderBox.globalToLocal(dragPosition);
    print("dragOffset: ${dragOffset}");
 }

  void dispose() {
    _proxyAnimationController?.dispose();
  }

  Widget _proxyDecorator(Widget child) {
    return AnimatedBuilder(animation: _proxyAnimationController!.view, builder: (context, child) {
      print("animation value: ${_proxyAnimationController!.view.value}");
      final double animValue = Curves.easeIn.transform(_proxyAnimationController!.view.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        child: child,
        elevation: elevation,
      );
    }, child: child,);
  }

  // why you need other calls?
  Widget createProxy(BuildContext context) {
    var position = this.dragPosition - this.dragOffset;
    return Positioned(
      top: position.dy,
      left: position.dx,
      child: SizedBox.fromSize(
        size: itemSize,
        child: child,
      ),
    );
  }

  void startDrag() {
    _overlayEntry = OverlayEntry(builder: createProxy);
    print("insert overlay");

    // Can you give the overlay to _Drag?
    final OverlayState overlay = Overlay.of(context)!;
    overlay.insert(_overlayEntry!);
  }

  @override
  void update(DragUpdateDetails details) {
    dragPosition += details.delta;
    onUpdate?.call(this, dragPosition, details.delta);

    _overlayEntry?.markNeedsBuild();
  }

  @override
  void end(DragEndDetails details) {
    _debug("onDrag end");
    onEnd?.call(this);

    this._endOrCancel();
  }

  @override
  void cancel() {
    _debug("onDrag cancel");
    onCancel?.call(this);

    this._endOrCancel();
  }

  void _endOrCancel()  {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}