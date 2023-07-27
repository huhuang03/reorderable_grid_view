import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoRemoveShadow extends StatefulWidget {
  const DemoRemoveShadow({Key? key}) : super(key: key);

  @override
  State<DemoRemoveShadow> createState() => _DemoRemoveShadowState();
}

class _DemoRemoveShadowState extends State<DemoRemoveShadow> {
  final data = List<int>.generate(10, (index) => index);
  double scrollSpeedVariable = 5;

  void add() {
    setState(() {
      data.add(data.length);
    });
  }

  Widget _buildGrid(BuildContext context) {
    return ReorderableGridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: 0.6,
      dragWidgetBuilderV2: DragWidgetBuilderV2(builder: (int index, Widget child, ImageProvider? screenshot) {
        return child;
      }),
      scrollSpeedController:
          (int timeInMilliSecond, double overSize, double itemSize) {
        log("scrollSpeedController call back called");
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
      children: data.map((e) => buildItem(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: _buildGrid(context));
  }

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      child: Text(index.toString()),
    );
  }
}
