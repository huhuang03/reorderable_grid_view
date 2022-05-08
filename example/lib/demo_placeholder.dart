import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoPlaceholder extends StatefulWidget {
  const DemoPlaceholder({Key? key}) : super(key: key);

  @override
  _DemoPlaceholderState createState() => _DemoPlaceholderState();
}

class _DemoPlaceholderState extends State<DemoPlaceholder> {
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Center(
        child: ReorderableGridView.builder(
          itemCount: 50,
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
          placeholderBuilder: (dragIndex, dropIndex, dragWidget) {
            return Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: SizedBox(),
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
