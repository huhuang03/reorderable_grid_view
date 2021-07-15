import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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


  OverlayEntry? _overlayEntry;
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

    final OverlayState overlay = Overlay.of(context)!;
    assert(_overlayEntry == null);

    _dragInfo = _DragInfo(
        item: item,
        tickerProvider: this,
        onUpdate: _onDragUpdate,
        onCancel: _onDragCancel,
        onEnd: _onDragEnd,
    );
    _dragInfo!.startDrag();

    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    print("insert overlay");
    overlay.insert(_overlayEntry!);

    return _dragInfo!;
  }

  _onDragUpdate(_DragInfo item, Offset position, Offset delta) {
    print("onDrag Update called");
    _overlayEntry?.markNeedsBuild();
  }

  _onDragCancel(_DragInfo item) {
    _dragReset();
    setState(() {

    });
  }

  _onDragEnd(_DragInfo item) {
    _dragReset();
    setState(() {

    });
  }

  _dragReset() {
    _overlayEntry?.remove();
    _overlayEntry = null;

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

  _DragInfo? _dragInfo;

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

class GridItemWrapper {
  int index;
  int? curIndex;
  int? nextIndex;

  GridItemWrapper({required this.index}) {
    curIndex = index;
    nextIndex = index;
  }

  // What's better offset with
  Offset adjustOffset(_Pos pos, double width, double height, double mainSpace,
      double crossSpace) {
    return Offset(pos.col.toDouble() + pos.col * mainSpace / width,
        pos.row + pos.row * crossSpace / height);
  }

  _Pos getBeginOffset(int crossAxisCount) {
    var origin = _getPos(index, crossAxisCount);
    var pos = _getPos(curIndex!, crossAxisCount);
    return _Pos(col: (pos.col - origin.col), row: (pos.row - origin.row));
  }

  _Pos getEndOffset(int crossAxisCount) {
    var origin = _getPos(index, crossAxisCount);
    var pos = _getPos(nextIndex!, crossAxisCount);
    return _Pos(col: (pos.col - origin.col), row: (pos.row - origin.row));
  }

  void animFinish() {
    curIndex = nextIndex;
  }

  bool hasMoved() {
    return index != curIndex;
  }

  @override
  String toString() {
    return 'GridItemWrapper{index: $index, curIndex: $curIndex, nextIndex: $nextIndex}';
  }
}

class _Pos {
  int row;
  int col;

  _Pos({required this.row, required this.col});

  _Pos operator -(_Pos other) =>
      _Pos(row: row - other.row, col: col - other.col);

  _Pos operator +(_Pos other) =>
      _Pos(row: row + other.row, col: col + other.col);

  Offset toOffset() {
    return Offset(col.toDouble(), row.toDouble());
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Pos &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

const _IS_DEBUG = true;

_debug(String msg) {
  if (_IS_DEBUG) {
    print("ReorderableGridView: " + msg);
  }
}

_Pos _getPos(int index, int crossAxisCount) {
  return _Pos(row: index ~/ crossAxisCount, col: index % crossAxisCount);
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
          return Text("Hello");
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

typedef _DragItemUpdate = void Function(_DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

// Give a a reason why I need you??
// Actually I don't think you are good.
// I will give you any you need.
class _DragInfo extends Drag {
  late int index;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onCancel;
  final _DragItemCallback? onEnd;
  final TickerProvider tickerProvider;

  late Size itemSize;
  late Widget child;
  late CapturedThemes _capturedThemes;
  Offset initialPosition;
  AnimationController? _proxyAnimationController;

  _DragInfo({
    required _ReorderableGridItemState item,
    required this.tickerProvider,
    required initialPosition,
    this.onUpdate,
    this.onCancel,
    this.onEnd,
  }) {
    index = item.index;
    child = item.widget.child;
    itemSize = item.context.size!;
    _capturedThemes = item.widget.capturedThemes;
    print("itemSize: ${itemSize}");
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

  Widget createProxy(BuildContext context) {
    return Positioned(
      top: 50,
      left: 50,
      child: SizedBox(
        width: 50,
        height: 50,
        child: child,
      ),
    );
  }

  void startDrag() {
    _proxyAnimationController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(microseconds: 250)
    );
    _proxyAnimationController!.forward();
  }

  @override
  void end(DragEndDetails details) {
    _debug("onDrag end");
    super.end(details);
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _debug("onDrag cancel");
    super.cancel();
    onCancel?.call(this);
  }
}