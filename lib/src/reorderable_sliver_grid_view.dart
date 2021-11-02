import 'package:flutter/widgets.dart';

// Can I be a stateful widget, because we need update the state. Ok, let's try this.
class ReorderableSliverGridView extends StatelessWidget {
  // can I hold the children? let's try.
  final List<Widget> children;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;

  const ReorderableSliverGridView({
    Key? key,
    this.children = const <Widget>[],
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.childAspectRatio,
  }): super(key: key);

  // can we do the logic?

  const ReorderableSliverGridView.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    children = const <Widget>[],
  }): this(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
  );

  // build the new child??
  @override
  Widget build(BuildContext context) {
    // we can't wrapper this?
    return SliverGrid.count(
      key: key,
      children: children,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

}