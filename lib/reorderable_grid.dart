library reorderable_grid;

import 'package:flutter/material.dart';

_Pos _getPos(int index, int crossAxisCount) {
  return _Pos(row: index ~/ crossAxisCount, col: index % crossAxisCount);
}

class RecordableGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final ReorderCallback onReorder;

  RecordableGridView({this.children, this.crossAxisCount, this.onReorder})
      : assert(children != null),
        assert(crossAxisCount != null),
        assert(onReorder != null);

  @override
  _RecordableGridViewState createState() => _RecordableGridViewState();
}

class _RecordableGridViewState extends State<RecordableGridView> {
  final GlobalKey _overlayKey =
      GlobalKey(debugLabel: '$RecordableGridView overlay key');

  // This entry contains the scrolling list itself.
  OverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = OverlayEntry(
      opaque: true,
      builder: (BuildContext context) {
        return _ReorderableGridContent(
          children: widget.children,
          crossAxisCount: widget.crossAxisCount,
          onReorder: widget.onReorder,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(key: _overlayKey, initialEntries: <OverlayEntry>[
      _listOverlayEntry,
    ]);
  }
}

class _ReorderableGridContent extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final ReorderCallback onReorder;

  _ReorderableGridContent({this.children, this.crossAxisCount, this.onReorder});

  @override
  __ReorderableGridContentState createState() =>
      __ReorderableGridContentState();
}

class __ReorderableGridContentState extends State<_ReorderableGridContent>
    with TickerProviderStateMixin<_ReorderableGridContent> {
  List<GridItemWrapper> _items = [];

  // The widget to move the dragging widget too after the current index.
  int _nextIndex = 0;

  // The location that the dragging widget occupied before it started to drag.
  int _dragStartIndex = 0;

  // occupies 占用
  // The index that the dragging widget currently occupies.
  int _currentIndex = 0;

  // The index that the dragging widget most recently left.
  // This is used to show an animation of the widget's position.
  int _ghostIndex = 0;

  // This controls the entrance of the dragging widget into a new place.
  AnimationController _entranceController;

  // This controls the 'ghost' of the dragging widget, which is left behind
  // where the widget used to be.
  AnimationController _ghostController;

  // How long an animation to reorder an element in the list takes.
  static const Duration _reorderAnimationDuration = Duration(milliseconds: 200);

  // The last computed size of the feedback widget being dragged.
  Size _draggingFeedbackSize;

  // The member of widget.children currently being dragged.
  //
  // Null if no drag is underway.
  Key _dragging;

  // The extent along the [widget.scrollDirection] axis to allow a child to
  // drop into when the user reorders list children.
  //
  // This value is used when the extents haven't yet been calculated from
  // the currently dragging widget, such as when it first builds.
  static const double _defaultDropAreaExtent = 100.0;

  _initItems() {
    _items.clear();
    for (var i = 0; i < widget.children.length; i++) {
      _items.add(GridItemWrapper(index: i));
    }
  }

  @override
  void initState() {
    super.initState();
    print("initState");
    _entranceController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);

    _ghostController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);

    _initItems();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _ghostController.dispose();
    super.dispose();
  }

  double get _dropAreaExtent {
    if (_draggingFeedbackSize == null) {
      return _defaultDropAreaExtent;
    }
    final double dropAreaWithoutMargin = _draggingFeedbackSize.width;
    return dropAreaWithoutMargin;
  }

  // Places the value from startIndex one space before the element at endIndex.
  void reorder(int startIndex, int endIndex) {
    // what to do??
    setState(() {
      if (startIndex != endIndex) widget.onReorder(startIndex, endIndex);
      // Animates leftover space in the drop area closed.
      // _ghostController.reverse(from: 0);
      _entranceController.reverse(from: 0);
      _initItems();
      _dragging = null;
    });
  }

  // Drops toWrap into the last position it was hovering over.
  void onDragEnded() {
    reorder(_dragStartIndex, _currentIndex);
  }

  // Animates the droppable space from _currentIndex to _nextIndex.
  void _requestAnimationToNextIndex() {
    print("_requestAnimationToNextIndex, state: ${_entranceController.status}");
    if (_entranceController.isCompleted) {
      _ghostIndex = _currentIndex;
      if (_nextIndex == _currentIndex) {
        return;
      }

      var temp = new List<int>.generate(_items.length, (index) => index);

      // if (_nextIndex > _dragStartIndex) {
      //   _nextIndex
      // }
      var old = temp.removeAt(_dragStartIndex);
      temp.insert(_nextIndex, old);

      for (var i = 0; i < _items.length; i++) {
        _items[i].nextIndex = temp[i];
      }

      _currentIndex = _nextIndex;
      // _ghostController.reverse(from: 1.0);
      _entranceController.forward(from: 0.0);
    }
  }

  // Requests animation to the latest next index if it changes during an animation.
  void _onEntranceStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _requestAnimationToNextIndex();
      });
    }
  }

  Widget _wrap(Widget toWrap, int index) {
    assert(toWrap.key != null);
    final _ReorderableGridViewChildGlobalKey keyIndexGlobalKey =
        _ReorderableGridViewChildGlobalKey(toWrap.key, this);

    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates,
        List<dynamic> rejectedCandidates, BoxConstraints constraints) {
      // now let's try scroll??
      Widget child = LongPressDraggable<Key>(
        data: toWrap.key,
        maxSimultaneousDrags: 1,
        // feed back is the view follow pointer
        feedback: Container(
          // actually, this constraints is not necessary here.
          // but how to calculate the toWrap size and give feedback.
          constraints: constraints,
          child: Material(elevation: 3.0, child: toWrap),
        ),
        child: toWrap,
        childWhenDragging: const SizedBox(),
        onDragStarted: () {
          _dragStartIndex = index;
          _ghostIndex = index;
          _currentIndex = index;

          // this is will set _entranceController to complete state.
          // ok ready to start animation
          _entranceController.value = 1.0;
          _dragging = toWrap.key;
        },
        onDragCompleted: onDragEnded,
        onDraggableCanceled: (Velocity velocity, Offset offset) {
          onDragEnded();
        },
      );

      var fromPos = _items[index].getBeginOffset(this.widget.crossAxisCount);
      var toPos = _items[index].getEndOffset(this.widget.crossAxisCount);
      if (fromPos != toPos) {
        return SlideTransition(
          position: Tween<Offset>(begin: fromPos, end: toPos)
              .animate(_entranceController),
          child: child,
        );
      }

      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // I think it's strange that I can get the right constraints at here.
        return DragTarget<Key>(
          builder: (context, acceptedCandidates, rejectedCandidates) =>
              buildDragTarget(
                  context, acceptedCandidates, rejectedCandidates, constraints),
          onWillAccept: (Key toAccept) {
            print("onWillAccept called for index: $index");
            // how can we change the state?
            _nextIndex = index;
            _requestAnimationToNextIndex();

            // now let's try scroll.
            return _dragging == toAccept && toAccept != toWrap.key;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      children: [
        for (int i = 0; i < widget.children.length; i++)
          // can we get grid view here??
          // no we can't
          _wrap(widget.children[i], i)
      ],
      crossAxisCount: widget.crossAxisCount,
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableGridViewChildGlobalKey extends GlobalObjectKey {
  const _ReorderableGridViewChildGlobalKey(this.subKey, this.state)
      : super(subKey);

  final Key subKey;

  final __ReorderableGridContentState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _ReorderableGridViewChildGlobalKey &&
        other.subKey == subKey &&
        other.state == state;
  }

  @override
  int get hashCode => hashValues(subKey, state);
}

class GridItemWrapper {
  int index;
  int curIndex;
  int nextIndex;

  GridItemWrapper({this.index}) : assert(index != null) {
    curIndex = index;
    nextIndex = index;
  }

  Offset getBeginOffset(int crossAxisCount) {
    var origin = _getPos(index, crossAxisCount);
    var pos = _getPos(curIndex, crossAxisCount);
    return Offset((pos.col - origin.col).toDouble(), (pos.row - origin.row).toDouble());
  }

  Offset getEndOffset(int crossAxisCount) {
    var origin = _getPos(index, crossAxisCount);
    var pos = _getPos(nextIndex, crossAxisCount);
    return Offset((pos.col - origin.col).toDouble(), (pos.row - origin.row).toDouble());
  }

  void animFinish() {
    nextIndex = curIndex;
  }
}

class _GridItemController {
  // how to trigger animation??
}

class _GridItem extends StatefulWidget {
  final int index;
  final Widget child;
  final crossAxisCount;

  _GridItem({this.index, this.child, this.crossAxisCount})
      : assert(index != null),
        assert(child != null),
        assert(crossAxisCount != null);

  @override
  __GridItemState createState() => __GridItemState();
}

class __GridItemState extends State<_GridItem>
    with TickerProviderStateMixin<_GridItem> {
  AnimationController _animController;
  Offset curOffset;

  @override
  void initState() {
    _animController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(begin: Offset(0, 0), end: Offset(-1.0, 0))
          .animate(_animController),
      child: widget.child,
    );
  }
}

class _Pos {
  int row;
  int col;

  _Pos({this.row, this.col})
      : assert(row != null),
        assert(col != null);
}
