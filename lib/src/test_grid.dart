import 'package:flutter/widgets.dart';

class TestGrid extends GridView {
  TestGrid(SliverGridDelegate gridDelegate) : super(
    gridDelegate: gridDelegate
  );

  @override
  Widget buildChildLayout(BuildContext context) {
    return super.buildChildLayout(context);
  }
}