library reorderable_grid;

import 'package:flutter/material.dart';

class RecordableGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;

  RecordableGridView({this.children, this.crossAxisCount})
      : assert(children != null),
        assert(crossAxisCount != null);

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

  _ReorderableGridContent({this.children, this.crossAxisCount});

  @override
  __ReorderableGridContentState createState() =>
      __ReorderableGridContentState();
}

class __ReorderableGridContentState extends State<_ReorderableGridContent> {
  Widget _wrap(Widget toWrap, BoxConstraints constraints) {
    print("parent constraints: ${constraints}");
    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates,
        List<dynamic> rejectedCandidates, BoxConstraints constraints) {
      return LongPressDraggable(
        maxSimultaneousDrags: 1,
        // feed back is the view follow pointer
        feedback: Container(
          // actually, this constraints is not necessary here.
          // but how to calculate the toWrap size and give feedback.
          constraints: constraints,
          child: Material(elevation: 3.0, child: toWrap),
        ),
        child: toWrap,
        onDragStarted: () => {print("onDrag Started")},
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // I think it's strange that I can get the right constraints at here.
        return DragTarget<Key>(
          builder: (context, acceptedCandidates, rejectedCandidates) =>
              buildDragTarget(
                  context, acceptedCandidates, rejectedCandidates, constraints),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return GridView.count(
          children: widget.children.map((e) => _wrap(e, constraints)).toList(),
          crossAxisCount: widget.crossAxisCount,
        );
      },
    );
  }
}
