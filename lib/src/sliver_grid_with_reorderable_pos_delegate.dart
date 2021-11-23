// bad name

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_mixin.dart';
import 'package:reorderable_grid_view/src/reorderable_item.dart';

// you are strange?
class SliverGridWithReorderablePosDelegate extends SliverGrid implements ReorderableChildPosDelegate {
  const SliverGridWithReorderablePosDelegate({
    Key? key,
    required SliverChildDelegate delegate,
    required SliverGridDelegate gridDelegate,
  }) : super(key: key, delegate: delegate, gridDelegate: gridDelegate);

  SliverGridWithReorderablePosDelegate.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
  }) : this(key: key,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childAspectRatio: childAspectRatio,
        )
      , delegate: SliverChildListDelegate(children));

  @override
  Offset getPos(int index, Map<int, ReorderableItemViewState> items, BuildContext context) {
    var renderObject = context.findRenderObject() as RenderSliverGrid?;

    if (renderObject == null) {
      return Offset.zero;
    }

    final SliverConstraints constraints = renderObject.constraints;
    final SliverGridLayout layout = gridDelegate.getLayout(constraints);


    // SliverGridGeometry(scrollOffset: 0.0, crossAxisOffset: 0.0, mainAxisExtent: 217.46031746031747, crossAxisExtent: 130.47619047619048), index: 0
    // SliverGridGeometry(scrollOffset: 0.0, crossAxisOffset: 140.47619047619048, mainAxisExtent: 217.46031746031747, crossAxisExtent: 130.47619047619048), index: 1
    // SliverGridGeometry(scrollOffset: 227.46031746031747, crossAxisOffset: 0.0, mainAxisExtent: 217.46031746031747, crossAxisExtent: 130.47619047619048), index: 3
    final SliverGridGeometry gridGeometry = layout.getGeometryForChildIndex(index);
    final rst = Offset(gridGeometry.crossAxisOffset, gridGeometry.scrollOffset);
    return rst;
  }


}