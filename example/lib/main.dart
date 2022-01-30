import 'package:example/demo_grid_builder.dart';
import 'package:example/demo_grid_sliver.dart';
import 'package:example/test_issue_24.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: Scaffold(
      //   body: DemoReorderableGrid(),
      // ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // return TestIssue24();
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Grid.count",
              ),
              Tab(
                text: "Grid.build",
              ),
              Tab(
                text: "SliverGrid.count",
              ),
              Tab(
                text: "Test Overlay",
              )
            ],
          ),
          title: Text(widget.title!),
        ),
        body: TabBarView(
          children: [
            DemoReorderableGrid(),
            DemoGridBuilder(),
            DemoGridSliver(),
            TestIssue24()
          ],
        ),
      ),
    );
  }
}

class DemoReorderableGrid extends StatefulWidget {
  @override
  _DemoReorderableGridState createState() => _DemoReorderableGridState();
}

class _DemoReorderableGridState extends State<DemoReorderableGrid> {
  final data = List<int>.generate(10, (index) => index);
  double scrollSpeedVariable = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ReorderableGridView.count(
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          childAspectRatio: 0.6, // 0 < childAspectRatio <= 1.0
          children: this.data.map((e) => buildItem(e)).toList(),
          scrollSpeedController:
              (int timeInMilliSecond, double overSize, double itemSize) {
            // print(
            //     "timeInMilliSecond: $timeInMilliSecond, overSize: $overSize, itemSize $itemSize");
            if (timeInMilliSecond > 1500) {
              scrollSpeedVariable = 15;
            } else {
              scrollSpeedVariable = 5;
            }
            return scrollSpeedVariable;
          },
          onReorder: (oldIndex, newIndex) {
            // print("reorder: $oldIndex -> $newIndex");
            setState(() {
              final element = data.removeAt(oldIndex);
              data.insert(newIndex, element);
            });
          },
          dragWidgetBuilder: (index, child) {
            return child;
            // return Card(
            //   color: Colors.blue,
            //   child: Text(index.toString()),
            // );
          },
          footer: [
            Card(
              child: Center(
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
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
