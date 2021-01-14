library reorderable_grid;

import 'package:flutter/material.dart';

class RecordableGridView extends StatefulWidget {

  final List<Widget> children;


  RecordableGridView({this.children}): assert(children != null);

  @override
  _RecordableGridViewState createState() => _RecordableGridViewState();
}

class _RecordableGridViewState extends State<RecordableGridView> {
  final GlobalKey _overlayKey = GlobalKey(debugLabel: '$RecordableGridView overlay key');

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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
        key: _overlayKey,
        initialEntries: <OverlayEntry>[
          _listOverlayEntry,
        ]);
  }
}


class _ReorderableGridContent extends StatefulWidget {
  final List<Widget> children;


  _ReorderableGridContent({this.children});

  @override
  __ReorderableGridContentState createState() => __ReorderableGridContentState();
}

class __ReorderableGridContentState extends State<_ReorderableGridContent> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
