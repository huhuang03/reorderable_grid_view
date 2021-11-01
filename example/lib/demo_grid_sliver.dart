import 'package:example/main.dart';
import 'package:flutter/material.dart';

class DemoGridSliver extends StatefulWidget {
  const DemoGridSliver({Key? key}) : super(key: key);

  @override
  _DemoGridSliverState createState() => _DemoGridSliverState();
}

class _DemoGridSliverState extends State<DemoGridSliver> {
  @override
  Widget build(BuildContext context) {
    // return Text("data");
    // return DemoReorderableGrid();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: FlutterLogo(),
        ),
        SliverToBoxAdapter(
          child: FlutterLogo(),
        ),
        // SliverToBoxAdapter(
        //   child: DemoReorderableGrid(),
        // )
      ],
    );
  }
}
