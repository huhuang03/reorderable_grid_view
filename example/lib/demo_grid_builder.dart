import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoGridBuilder extends StatefulWidget {
  const DemoGridBuilder({Key? key}) : super(key: key);

  @override
  _DemoGridBuilderState createState() => _DemoGridBuilderState();
}

class _DemoGridBuilderState extends State<DemoGridBuilder> {
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Center(
        child: ReorderableGridView.builder(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          itemCount: 5,
          itemBuilder: (context, index) => buildItem(index),
          onReorder: (oldIndex, newIndex) {
            print("reorder: $oldIndex -> $newIndex");
            setState(() {
              print("reorder: $oldIndex -> $newIndex");
              setState(() {
                final element = data.removeAt(oldIndex);
                data.insert(newIndex, element);
              });
            });
          },
          dragWidgetBuilder: (index, child) {
            return Card(
              color: Colors.blue,
              child: Text(index.toString()),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.6,
          ),
        ),
      ),
    );
  }

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      child: Text(data[index].toString()),
    );
  }
}
