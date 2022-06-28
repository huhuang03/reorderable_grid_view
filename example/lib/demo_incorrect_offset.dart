import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoInCorrectOffset extends StatefulWidget {
  @override
  _DemoInCorrectOffsetState createState() => _DemoInCorrectOffsetState();
}

class _DemoInCorrectOffsetState extends State<DemoInCorrectOffset> {
  final data = List<int>.generate(10, (index) => index);
  double scrollSpeedVariable = 5;

  Widget _buildGrid(BuildContext context) {
    return ReorderableGridView.count(
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      crossAxisCount: 3,
      childAspectRatio: 0.6, // 0 < childAspectRatio <= 1.0
      children: this.data.map((e) => buildItem(e)).toList(),
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
        print("onDragStart $dragIndex");
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
      header: [
        Card(
          child: Center(
            child: Icon(Icons.delete),
          ),
        ),
      ],
      footer: [
        Card(
          child: Center(
            child: Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          SizedBox(width: 100,),
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
