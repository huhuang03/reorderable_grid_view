import 'package:flutter/widgets.dart';

class ReorderableSliverGridVie extends StatelessWidget {
  // can I hold the children? let's try.
  final List<Widget> children;
  const ReorderableSliverGridVie({Key? key,
    this.children = const <Widget>[]}): super(key: key);

  // can we do the logic?

  const ReorderableSliverGridVie.count({
    Key? key,
    required int crossAxisCount,
    double mainAxisSpacing = 0.0,
    double crossAxisSpacing = 0.0,
    double childAspectRatio = 1.0,
    children = const <Widget>[],
  }): this(key: key, children: children);

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

}

class AA extends StatelessWidget {
  const AA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverGrid.count(crossAxisCount: 4);
    return Container();
  }
}
