import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoDragEnableConfig extends StatefulWidget {
  const DemoDragEnableConfig({Key? key}) : super(key: key);

  @override
  State<DemoDragEnableConfig> createState() => _DemoDragEnableConfigState();
}

/// Wrap child in ReorderableWrapperWidget and
/// reorderable item in ReorderableItemView
class _DemoDragEnableConfigState extends State<DemoDragEnableConfig> {
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (builder) => ReorderableGridView.count(
            onReorder: (dragIndex, dropIndex) {
              setState(() {
                print('dragIndex: $dragIndex, dropIndex: $dropIndex');
                var item = data.removeAt(dragIndex);
                data.insert(dropIndex, item);
                print('after swap: $data');
              });
            },
            dragEnableConfig: (index) {
              return data[index].isOdd;
            },
            crossAxisCount: 3,
            children: data.map((e) {
              return Card(
                key: ValueKey(e),
                color: e.isOdd? Colors.cyanAccent: Colors.deepOrangeAccent,
                child: Text(e.isOdd? 'Reorderable_$e' : 'Block_$e'),
              );
            }).toList())
            // builder: (builder) => ReorderableWrapperWidget(
            //       child: GridView.builder(
            //           gridDelegate:
            //               const SliverGridDelegateWithFixedCrossAxisCount(
            //                   crossAxisCount: 3),
            //           itemCount: data.length * 2,
            //           itemBuilder: (context, index) {
            //             if (index % 2 == 0) {
            //               return const Card(
            //                 color: Colors.black12,
            //                 child: Text("Sticky"),
            //               );
            //             } else {
            //               var indexForReorderable = (index / 2).floor();
            //               var itemData = data[indexForReorderable];
            //               return ReorderableItemView(
            //                   key: ValueKey(indexForReorderable),
            //                   index: indexForReorderable,
            //                   child: Card(
            //                     child: Text("R $itemData"),
            //                   ));
            //             }
            //           }),
            //       // the drag and drop index is from (index passed to ReorderableItemView)
            //     )
        )
      ],
    );
  }
}
