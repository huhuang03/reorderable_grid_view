
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_mixin.dart';
import 'package:reorderable_grid_view/src/reorderable_item.dart';

import '../reorderable_grid_view.dart';

// why you want the __items?
class GridChildPosDelegate extends ReorderableChildPosDelegate {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const GridChildPosDelegate({
    required this.crossAxisCount,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
  });

  @override
  Offset getPos(int index, Map<int, ReorderableItemViewState> items, BuildContext context) {

    // can I get pos by child?
    var child = items[index];
    // I think the better is use the sliverGrid?
    var childObject = child?.context.findRenderObject();

    // so from the childObject, I still can't get pos?
    if (childObject == null) {
      print("index: $index is null");
    } else {
      print("index: $index, pos: ${childObject.constraints}");
      if (childObject is RenderSliver) {
        print("index: $index, pos: ${childObject.constraints}");
      } else if (childObject is RenderBox){
        // childObject.localToGlobal(point)
        print("index: $index, pos: ${childObject.semanticBounds}");
      } else {
        print("index: $index, $childObject");
      }
    }

    // will it be not ready?
    // index and the next is not ready?
    // ok, but let's do it

    double width;
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject == null) {
      return Offset.zero;
    }

    if (renderObject is RenderSliver) {
      width = renderObject.constraints.crossAxisExtent;
    } else {
      width = (renderObject as RenderBox).size.width;
    }

    double itemWidth = (width -
        (crossAxisCount - 1) * crossAxisSpacing) /
        crossAxisCount;

    int row = index ~/ crossAxisCount;
    int col = index % crossAxisCount;

    double x = (col - 1) * (itemWidth + crossAxisSpacing);
    double y = (row - 1) *
        (itemWidth / (childAspectRatio) + mainAxisSpacing);
    return Offset(x, y);
  }

}

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
  }):  super(key: key);

  @override
  ReorderableGridWrapperViewState createState() => ReorderableGridWrapperViewState();
}

class ReorderableGridWrapperViewState extends State<ReorderableGridWrapperView> with TickerProviderStateMixin<ReorderableGridWrapperView>, ReorderableGridStateMixin {
  ReorderableChildPosDelegate? _childPosDelegator;

  @override
  ReorderableChildPosDelegate get childPosDelegator {
    if (_childPosDelegator == null)  {
      _childPosDelegator = new GridChildPosDelegate(
          crossAxisCount: widget.crossAxisCount,
          mainAxisSpacing: widget.mainAxisSpacing,
          crossAxisSpacing: widget.crossAxisSpacing,
          childAspectRatio: widget.childAspectRatio,
      );
    }
    return _childPosDelegator!;
  }
}
