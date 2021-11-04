# ReorderableGridView

Copy from official ReorderableListView

# Usage:
```
dependencies:
  reorderable_grid_view: ^2.1.0-alpha.1
```

# Example
<img src="https://github.com/huhuang03/reorderable_grid_view/blob/master/example/gifs/example.gif?raw=true" width="360" title="Sceenshot">

``` dart
class _MyHomePageState extends State<MyHomePage> {
  final data = [1, 2, 3, 4, 5];

  @override
  Widget build(BuildContext context) {
    Widget buildItem(String text) {
      return Card(
        key: ValueKey(text),
        child: Text(text),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        // use ReorderableGridView.count() when version >= 2.0.0
        // else use ReorderableGridView()
        child: ReorderableGridView.count(
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
}
```

## Other

`Reorderable.builder` and `ReorderableSliverGridView.count` can work.

If you want use `Reorderable.builder`. You should look at [issue #18](https://github.com/huhuang03/reorderable_grid_view/issues/18#issuecomment-938628435).

# Important
as issue #17 says. There's some broken api in MultiDragGestureRecognizer. So if you have some issue relative to MultiDragGestureRecognizer.

Please try both 1.1.x and 1.2.x version.

# TODO
- fix padding.
- maybe better calculate the pos of child
- impl the ReorderableGrid.extent