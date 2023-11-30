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
    dragEnableConfig(index) {
      return data[index].isOdd;
    }

    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (builder) => ReorderableGridView.count(
            onReorder: (dragIndex, dropIndex) {
              setState(() {
                if (dragIndex == dropIndex) {
                  return;
                }
                var dragRight = dragIndex < dropIndex;
                var di = dragRight? 1: -1;
                var needMoveIndex = [];
                for (var i = dragIndex; i != dropIndex; i += di) {
                  if (dragEnableConfig(i)) {
                    needMoveIndex.add(i);
                  }
                }
                for (var i = 0; i < needMoveIndex.length - 2; i++) {
                  var i1 = data[i];
                  var i2 = data[i + 1];

                  var tmp = data[i1];
                  data[i1] = data[i2];
                  data[i2] = tmp;
                }
              });
            },
            dragEnableConfig: dragEnableConfig,
            crossAxisCount: 3,
            children: data.map((e) {
              return Card(
                key: ValueKey(e),
                color: e.isOdd? Colors.cyanAccent: Colors.deepOrangeAccent,
                child: Text(e.isOdd? 'Reorderable_$e' : 'Block_$e'),
              );
            }).toList())
        )
      ],
    );
  }
}
