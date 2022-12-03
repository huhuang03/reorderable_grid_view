import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoCustom extends StatefulWidget {
  const DemoCustom({Key? key}) : super(key: key);

  @override
  State<DemoCustom> createState() => _DemoCustomState();
}

/// Wrap child in ReorderableWrapperWidget and
/// reorderable item in ReorderableItemView
class _DemoCustomState extends State<DemoCustom> {
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
            builder: (builder) => ReorderableWrapperWidget(
                  child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      itemCount: data.length * 2,
                      itemBuilder: (context, index) {
                        if (index % 2 == 0) {
                          return const Card(
                            color: Colors.black12,
                            child: Text("Sticky"),
                          );
                        } else {
                          var realIndex = (index / 2).floor();
                          var itemData = data[realIndex];
                          return ReorderableItemView(
                              key: ValueKey(realIndex),
                              index: realIndex,
                              child: Card(
                                child: Text("R $itemData"),
                              ));
                        }
                      }),
                  // the drag and drop index is from (index passed to ReorderableItemView)
                  onReorder: (dragIndex, dropIndex) {
                    setState(() {
                      var item = data.removeAt(dragIndex);
                      data.insert(dropIndex, item);
                    });
                  },
                ))
      ],
    );
  }
}
