
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_mixin.dart';

import '../reorderable_grid_view.dart';

class ReorderableGridWrapperView extends StatefulWidget with ReorderableGridWidgetMixin {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  final ReorderCallback onReorder;
  final DragWidgetBuilder? dragWidgetBuilder;
  final ScrollSpeedController? scrollSpeedController;

  final Widget child;

  const ReorderableGridWrapperView({
    Key? key,
    required this.child,

    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,

    required this.onReorder,
    this.dragWidgetBuilder,
    this.scrollSpeedController,
  }) : super(key: key);

  @override
  ReorderableGridWrapperViewState createState() => ReorderableGridWrapperViewState();
}

class ReorderableGridWrapperViewState extends State<ReorderableGridWrapperView> with TickerProviderStateMixin<ReorderableGridWrapperView>, ReorderableGridStateMixin {
}
