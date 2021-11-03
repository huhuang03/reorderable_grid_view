import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoGridSliver extends StatefulWidget {
  const DemoGridSliver({Key? key}) : super(key: key);

  @override
  _DemoGridSliverState createState() => _DemoGridSliverState();
}

class _DemoGridSliverState extends State<DemoGridSliver> {
  final data = List<int>.generate(50, (index) => index);
  double scrollSpeedVariable = 5;

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      child: Text(index.toString()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // return Text("data");
    // return DemoReorderableGrid();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FlutterLogo(),
        ),
        SliverToBoxAdapter(
          child: FlutterLogo(),
        ),
        ReorderableSliverGridView(
          onReorder: (oldIndex, newIndex) {},
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 0.6, // 0 < childAspectRatio <= 1.0
          children: this.data.map((e) => buildItem(e)).toList(),
        ),
        SliverToBoxAdapter(
          child: FlutterLogo(),
        ),
        // SliverGrid.count(crossAxisCount: 3),
      ],
    );
  }
}
