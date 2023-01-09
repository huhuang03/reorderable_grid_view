import 'package:example/demo/demo_custom.dart';
import 'package:example/demo/demo_grid_sliver.dart';
import 'package:example/demo/demo_reorderable_count_enable.dart';
import 'package:example/demo_incorrect_offset.dart';
import 'package:example/demo/demo_reorderable_count.dart';
import 'package:flutter/material.dart';

import 'demo/demo_item_rebuild.dart';

void main() {
  runApp(MyApp());
}

typedef Next = Widget Function();

class Item {
  String name = "";
  Next next;

  Item(this.name, this.next);
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final items = [
    Item("ReorderableGrid.count", () => const DemoReorderableGrid()),
    Item("Custom", () => const DemoCustom()),
    Item("InCorrect Offset", () => const DemoInCorrectOffset()),
    Item("Sliver Grid", () => const DemoGridSliver()),
    Item("Item Rebuild", () => const DemoItemRebuild()),
    Item("Enable", () => const DemoEnable()),
    Item("Nested router", () => Navigator(
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        late WidgetBuilder builder;
        switch (settings.name) {
          case '/':
            builder = (context) => const DemoReorderableGrid();
            break;
        }
        return MaterialPageRoute(builder: builder);
    },))
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            appBar: AppBar(
              title: const Text("Reorderable Demo"),
            ),
            body: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  var item = items[index];
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: Text(item.name),
                                      ),
                                      body: item.next(),
                                    )));
                      },
                      child: ListTile(title: Text(item.name)));
                })));
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, this.title}) : super(key: key);
//
//   final String? title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     // return TestIssue24();
//     return DefaultTabController(
//       length: 5,
//       child: Scaffold(
//         appBar: AppBar(
//           bottom: const TabBar(
//             tabs: [
//               Tab(
//                 text: "Grid.count",
//               ),
//               Tab(
//                 text: "Grid.build",
//               ),
//               Tab(
//                 text: "Placeholder",
//               ),
//               Tab(
//                 text: "SliverGrid.count",
//               ),
//               Tab(
//                 text: "Test Overlay",
//               )
//             ],
//           ),
//           title: Text(widget.title!),
//         ),
//         body: const TabBarView(
//           children: [
//             DemoReorderableGrid(),
//             DemoGridBuilder(),
//             DemoPlaceholder(),
//             DemoGridSliver(),
//             TestIssue24()
//           ],
//         ),
//       ),
//     );
//   }
// }
