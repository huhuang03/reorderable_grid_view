// bad name

import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

class SliverGridWithReorderablePosDelegate extends SliverGrid {
  const SliverGridWithReorderablePosDelegate({
    super.key,
    required super.delegate,
    required super.gridDelegate,
  });

  SliverGridWithReorderablePosDelegate.count({
    super.key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    List<Widget> children = const <Widget>[],
  }) : super(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildListDelegate(children));
}
