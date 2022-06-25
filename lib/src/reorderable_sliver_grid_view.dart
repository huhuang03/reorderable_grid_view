import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/sliver_grid_with_reorderable_pos_delegate.dart';

import '../reorderable_grid_view.dart';


class ReorderableSliverGridView extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  final ReorderCallback onReorder;
  final DragWidgetBuilder? dragWidgetBuilder;
  final ScrollSpeedController? scrollSpeedController;
  final PlaceholderBuilder? placeholderBuilder;
  final OnDragStart? onDragStart;
  final Duration dragStartDelay;
  final bool dragEnabled;

  const ReorderableSliverGridView({
    Key? key,
    this.children = const <Widget>[],
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
    required this.onReorder,
    this.dragStartDelay = kLongPressTimeout,
    this.dragWidgetBuilder,
    this.scrollSpeedController,
    this.placeholderBuilder,
    this.onDragStart,
    this.dragEnabled = true,
  }) : super(key: key);

  const ReorderableSliverGridView.count({
    Key? key,
    required int crossAxisCount,
    required ReorderCallback onReorder,
    OnDragStart? onDragStart,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    Duration dragStartDelay = kLongPressTimeout,
    children = const <Widget>[],
    bool dragEnabled = true,
  }) : this(
          key: key,
          onReorder: onReorder,
          children: children,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
          onDragStart: onDragStart,
          dragStartDelay: dragStartDelay,
          dragEnabled: dragEnabled,
        );

  @override
  Widget build(BuildContext context) {
    var child = SliverGridWithReorderablePosDelegate.count(
        key: key,
        children: ReorderableItemView.wrapMeList([], children, []),
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio);

    return ReorderableWrapperWidget(
      child: child,
      onReorder: onReorder,
      dragWidgetBuilder: dragWidgetBuilder,
      scrollSpeedController: scrollSpeedController,
      placeholderBuilder: placeholderBuilder,
      onDragStart: onDragStart,
    );
  }
}
