import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoCustom extends StatefulWidget {
  const DemoCustom({Key? key}) : super(key: key);

  @override
  State<DemoCustom> createState() => _DemoCustomState();
}

class _DemoCustomState extends State<DemoCustom> {
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return ReorderableWrapperWidget(child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: data.length,
        itemBuilder: (context, index) {
          if (index % 2 == 0) {
            return Card(
              child: Text("O $index"),
            );
          } else {
            return ReorderableItemView(child: Card(
              child: Text("R $index"),
            ), key: UniqueKey(), index: index);
          }
        }),
      onReorder: (oldIndex, newIndex) {
        var item = data.remove(oldIndex);
        // data.add(values)
      },);

  }
}
