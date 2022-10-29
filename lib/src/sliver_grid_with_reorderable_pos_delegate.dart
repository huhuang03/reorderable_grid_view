// bad name

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class SliverGridWithReorderablePosDelegate extends SliverGrid {
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
  }) : this(
            key: key,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildListDelegate(children));
}
