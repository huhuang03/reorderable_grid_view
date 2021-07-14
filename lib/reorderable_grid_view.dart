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


  MultiDragGestureRecognizer? _recognizer;

  void startDragRecognizer(int index, PointerDownEvent event, MultiDragGestureRecognizer<MultiDragPointerState> recognizer) {
    _dragIndex = index;
    _recognizer = recognizer
        ..onStart = _onDragStart
        ..addPointer(event);
  }

  int? _dragIndex;

  Drag _onDragStart(Offset position) {
    print("drag start!!, __items size: ${__items.length}, _dragIndex: ${_dragIndex}");
    // how can you do this?
    assert(_dragInfo == null);

    final __ReorderableGridItemState item = __items[_dragIndex!]!;
    item.dragging = true;
    item.rebuild();

    _dragInfo = _DragInfo(
        item: item,
        onUpdate: _onDragUpdate,
        onCancel: _onDragCancel,
        onEnd: _onDragEnd,
    );

    return _dragInfo!;
  }

  _onDragUpdate(_DragInfo item, Offset position, Offset delta) {
    print("onDrag Update called");
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
    if (_dragIndex != null)  {
      final __ReorderableGridItemState item = __items[_dragIndex!]!;
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
      children.add(_ReorderableGridItem(child: child, key: child.key!, index: i));
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

  final Map<int, __ReorderableGridItemState> __items = <int, __ReorderableGridItemState>{};

  _DragInfo? _dragInfo;

  void _registerItem(__ReorderableGridItemState item) {
    __items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unRegisterItem(int index, __ReorderableGridItemState item) {
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

  const _ReorderableGridItem({
    required this.child,
    required this.key,
    required this.index
  }): super(key: key);

  @override
  __ReorderableGridItemState createState() => __ReorderableGridItemState();
}

class __ReorderableGridItemState extends State<_ReorderableGridItem> {
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
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
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
      print("build called with at ${index}, _dragging: ${_dragging}");
      if (_dragging) {
        // why put you in the Listener??
        return SizedBox();
      }
      var _offset = offset;
      return Transform(
          transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
          child: child,
      );
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

class _DragInfo extends Drag {
  late int index;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onCancel;
  final _DragItemCallback? onEnd;

  _DragInfo({
    required __ReorderableGridItemState item,
    this.onUpdate,
    this.onCancel,
    this.onEnd
  }) {
    index = item.index;
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