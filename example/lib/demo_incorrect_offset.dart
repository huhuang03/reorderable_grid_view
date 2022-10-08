import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoInCorrectOffset extends StatefulWidget {
  const DemoInCorrectOffset({Key? key}) : super(key: key);

  @override
  State<DemoInCorrectOffset> createState() => _DemoInCorrectOffsetState();
}

class _DemoInCorrectOffsetState extends State<DemoInCorrectOffset> {
  final data = List<int>.generate(10, (index) => index);
  double scrollSpeedVariable = 5;

  Widget _buildGrid(BuildContext context) {
    return ReorderableGridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: 0.6,
      scrollSpeedController:
          (int timeInMilliSecond, double overSize, double itemSize) {
        if (timeInMilliSecond > 1500) {
          scrollSpeedVariable = 15;
        } else {
          scrollSpeedVariable = 5;
        }
        return scrollSpeedVariable;
      },
      // option
      onDragStart: (dragIndex) {
        log("onDragStart $dragIndex");
      },
      onReorder: (oldIndex, newIndex) {
        // print("reorder: $oldIndex -> $newIndex");
        setState(() {
          final element = data.removeAt(oldIndex);
          data.insert(newIndex, element);
        });
      },
      // option
      dragWidgetBuilder: (index, child) {
        return child;
      },
      header: const [
        Card(
          child: Center(
            child: Icon(Icons.delete),
          ),
        ),
      ],
      footer: const [
        Card(
          child: Center(
            child: Icon(Icons.add),
          ),
        ),
      ], // 0 < childAspectRatio <= 1.0
      children: data.map((e) => buildItem(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          const SizedBox(
            width: 100,
          ),
          Expanded(child: _buildGrid(context)),
        ],
      ),
    );
  }

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      child: Text(index.toString()),
    );
  }
}
