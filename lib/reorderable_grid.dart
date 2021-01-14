library reorderable_grid;

import 'package:flutter/material.dart';

class RecordableGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;

  RecordableGridView({this.children, this.crossAxisCount})
      : assert(children != null);

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


  Widget _wrap(Widget toWrap) {
    Widget buildDragTarget(BuildContext context, List<Key> acceptedCandidates,
        List<dynamic> rejectedCandidates) {
        return toWrap;
    }

    return DragTarget<Key>(
      builder: buildDragTarget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      children: widget.children.map((e) => _wrap(e)),
      crossAxisCount: widget.crossAxisCount,
    );
  }
}
