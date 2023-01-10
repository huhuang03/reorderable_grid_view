import 'dart:developer';

import 'package:example/demo/demo_item_rebuild.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class DemoPageView extends StatefulWidget {
  const DemoPageView({Key? key}) : super(key: key);

  @override
  State<DemoPageView> createState() => _DemoPageViewState();
}

class _DemoPageViewState extends State<DemoPageView> {
  final widgets = List<Widget>.generate(10, (index) => Item(no: index));
  double scrollSpeedVariable = 5;

  void add() {
    setState(() {
      widgets.add(Item(no: widgets.length));
    });
  }

  Widget _buildList(BuildContext context) {
    return Column(children: [
      Expanded(
        child: PageView(
          children: widgets.map((e) => e).toList(),
        ),
      ),
      const SizedBox(
        height: 100,
      )
    ],);
  }

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
          final element = widgets.removeAt(oldIndex);
          widgets.insert(newIndex, element);
        });
      },
      // option
      dragWidgetBuilder: (index, child) {
        return child;
      },
      header: [
        Card(
          child: InkWell(
            onTap: () {
              print("add called");
              add();
            },
            child: const Center(
              child: Icon(Icons.add)),
          ),
        ),
      ],
      footer: [
        Card(
          child: InkWell(
            onTap: () {
              if (widgets.isNotEmpty) {
                setState(() {
                  widgets.removeLast();
                });
              }
            },
            child: const Center(
              child: Icon(Icons.delete)),
          ),
        ),
      ], // 0 < childAspectRatio <= 1.0
      children: widgets.map((e) => Container(
        key: ValueKey(e),
        child: e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: _buildGrid(context)),
        _buildList(context)
      ],
    );
  }

  Widget buildItem(int index) {
    return Card(
      key: ValueKey(index),
      child: Text(index.toString()),
    );
  }
}
