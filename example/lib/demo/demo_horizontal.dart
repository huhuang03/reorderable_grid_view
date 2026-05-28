import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoHorizontal extends StatefulWidget {
  const DemoHorizontal({Key? key}) : super(key: key);

  @override
  State<DemoHorizontal> createState() => _DemoHorizontalState();
}

class _DemoHorizontalState extends State<DemoHorizontal> {
  final data = List<int>.generate(20, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ReorderableGridView.count(
        scrollDirection: Axis.horizontal,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 140,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            final element = data.removeAt(oldIndex);
            data.insert(newIndex, element);
          });
        },
        children: data.map((index) => buildItem(index)).toList(),
      ),
    );
  }

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      color: Colors.teal[(index % 8 + 1) * 100],
      child: Center(
        child: Text(
          index.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
