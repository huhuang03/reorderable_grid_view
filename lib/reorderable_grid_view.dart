import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_state.dart';

/// Build the drag widget under finger when dragging.
/// The index here represents the index of current dragging widget
/// The child here represents the current index widget
typedef DragWidgetBuilder = Widget Function(int index, Widget child);

/// Control the scroll speed if drag over the boundary.
/// We can pass time here??
/// [timeInMilliSecond] is the time passed.
/// [overPercentage] is the scroll over the boundary percentage
/// [overSize] is the pixel drag over the boundary
/// [itemSize] is the drag item size
/// Maybe you need decide the scroll speed by the given param.
/// return how many pixels when scroll in 14ms(maybe a frame). 5 is the default
typedef ScrollSpeedController = double Function(
    int timeInMilliSecond, double overSize, double itemSize);

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
  final DragWidgetBuilder? dragWidgetBuilder;
  final ScrollSpeedController? scrollSpeedController;

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
  final double? childAspectRatio;

  /// I think anti multi drag is loss performance.
  /// So default is false, and only set if you care this case.
  final bool antiMultiDrag;

  ReorderableGridView({
    Key? key,
    required this.children,
    this.dragWidgetBuilder,
    this.scrollSpeedController,
    this.clipBehavior = Clip.hardEdge,
    this.cacheExtent,
    this.semanticChildCount,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
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
    @Deprecated("Not used any more, because always anti multiDrag now.")
    this.antiMultiDrag = false,
  }) : super(key: key);

  @override
  ReorderableGridViewState createState() => ReorderableGridViewState();
}


const _IS_DEBUG = true;

_debug(String msg) {
  if (_IS_DEBUG) {
    print("ReorderableGridView: " + msg);
  }
}

