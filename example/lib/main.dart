import 'package:example/example_reorderable_list.dart';
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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(text: "Grid",),
                Tab(text: "List",)
              ],
            ),
            title: Text(widget.title),
          ),
          body: TabBarView(
            children: [
              DemoReorderableGrid(),
              ExampleReorderableList(),
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
  final data = List<int>.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ReorderableGridView(
          antiMultiDrag: true,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 3,
          children: this.data.map((e) => buildItem("$e")).toList(),
          onReorder: (oldIndex, newIndex) {
            setState(() {
              final element = data.removeAt(oldIndex);
              data.insert(newIndex, element);
            });
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

  Widget buildItem(String text) {
    return Card(
      key: ValueKey(text),
      child: Text(text),
    );
  }
}
