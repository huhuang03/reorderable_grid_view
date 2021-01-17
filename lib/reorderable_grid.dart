library reorderable_grid;

import 'dart:math';

import 'package:flutter/material.dart';

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
  // final GlobalKey _overlayKey =
  //     GlobalKey(debugLabel: '$RecordableGridView overlay key');
  //
  // // This entry contains the scrolling list itself.
  // OverlayEntry _listOverlayEntry;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   _listOverlayEntry = OverlayEntry(
  //     opaque: true,
  //     builder: (BuildContext context) {
  //       return _ReorderableGridContent(
  //         children: widget.children,
  //         crossAxisCount: widget.crossAxisCount,
  //         onReorder: widget.onReorder,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
      return _ReorderableGridContent(
        children: widget.children,
        crossAxisCount: widget.crossAxisCount,
        onReorder: widget.onReorder,
      );
    // return Overlay(key: _overlayKey, initialEntries: <OverlayEntry>[
    //   _listOverlayEntry,
    // ]);
  }
}

class _ReorderableGridContent extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final ReorderCallback onReorder;
  final bool shrinkWrap;

  _ReorderableGridContent({this.children, this.crossAxisCount, this.onReorder, this.shrinkWrap});

  @override
  __ReorderableGridContentState createState() =>
      __ReorderableGridContentState();
}

class __ReorderableGridContentState extends State<_ReorderableGridContent>
    with TickerProviderStateMixin<_ReorderableGridContent> {
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

  @override
  void initState() {
    super.initState();
    _entranceController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
    _entranceController.addStatusListener(_onEntranceStatusChanged);

    _ghostController =
        AnimationController(vsync: this, duration: _reorderAnimationDuration);
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
    setState(() {
      if (startIndex != endIndex) widget.onReorder(startIndex, endIndex);
      // Animates leftover space in the drop area closed.
      _ghostController.reverse(from: 0);
      _entranceController.reverse(from: 0);
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
      _currentIndex = _nextIndex;
      _ghostController.reverse(from: 1.0);
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

  Widget _wrap(Widget toWrap, BoxConstraints constraints, int index) {
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

      // Determine the size of the drop area to show under the dragging widget.
      Widget spacing = SizedBox(width: _dropAreaExtent);

      var direction = _nextIndex - _currentIndex;
      var isForward = direction < 0;


      if (direction == 0) {
        return child;
      } else {
        var row = index / widget.crossAxisCount;
        var column = index % widget.crossAxisCount;
        var targetRow = row;
        var targetColumn = column;

        if (isForward) {// other backward
          if (column == widget.crossAxisCount - 1) {  // cross line
            targetRow += 1;
            targetColumn = 0;
          } else {
            targetColumn = column + 1;
          }
        } else {
          if (column == 0) {  // cross line
            targetRow -= 1;
            targetColumn = widget.crossAxisCount - 1;
          } else {
            targetColumn = column - 1;
          }
        }

        var minIndex = min(_nextIndex, _currentIndex);
        var maxIndex = max(_nextIndex, _currentIndex);

        if (index >= minIndex && index <= maxIndex) {
          return SlideTransition(
            position: Tween<Offset>(begin: Offset(0, 0), end: Offset((targetColumn - column).toDouble(), targetRow - row)).animate(
                _entranceController),
            child: child,
          );
        }
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // what we need to know it's every child
        // The gridView know all his child.
        return GridView.count(
          children: [
            for (int i = 0; i < widget.children.length; i++)
              _wrap(widget.children[i], constraints, i)
          ],
          crossAxisCount: widget.crossAxisCount,
        );
      },
    );
  }
}

class _GridWrapper extends BoxScrollView {

  @override
  Widget buildChildLayout(BuildContext context) {
    return SliverGrid();
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


class _ChildWrapper extends StatefulWidget {
  final int index;
  final Widget toWrap;

  _ChildWrapper({this.index, this.toWrap}):
        assert(index != null), assert(toWrap != null);

  @override
  __ChildWrapperState createState() => __ChildWrapperState();
}

class __ChildWrapperState extends State<_ChildWrapper> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class OverlayWrapper extends StatefulWidget {
  final Widget child;

  OverlayWrapper({this.child}): assert(child != null);

  @override
  _OverlayWrapperState createState() => _OverlayWrapperState();
}

class _OverlayWrapperState extends State<OverlayWrapper> {
  final GlobalKey _overlayKey = GlobalKey(debugLabel: '$OverlayWrapper overlay key');

  // This entry contains the scrolling list itself.
  OverlayEntry _listOverlayEntry;

  @override
  void initState() {
    super.initState();
    _listOverlayEntry = OverlayEntry(
      opaque: true,
      builder: (BuildContext context) {
        return this.widget.child;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      initialEntries: [
        _listOverlayEntry
      ],
    );
  }
}


