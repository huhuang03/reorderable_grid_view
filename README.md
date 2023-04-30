# ReorderableGridView

Copy from official ReorderableListView

# Usage:
```
dependencies:
  reorderable_grid_view: ^2.2.6
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

# Options
| option                  | desc                                                                                  |
|-------------------------|---------------------------------------------------------------------------------------|
| `dragWidgetBuilderV2`   | the drag widget builder                                                               |
| `restrictDragScope`     | restrict drag scope to ReorderableGridView, not drag over the scree, default is false |
| `dragStartDelay`        | the longPress time                                                                    |
| `scrollSpeedController` | control how speed when scroll down when drag out of viewport                          |

## `dragWidgetBuilderV2`
Normaly if you can do like this:

```
dragWidgetBuilderV2: DragWidgetBuilderV2(
	isScreenshotDragWidget: false,
	builder: (index, child, screenshot) {
		return child;
	}
)
```
- child is you dragging widget.

And if you dragging widget has some state, the callback's child can't access the state. So you can do a screenshot like this.
```
dragWidgetBuilderV2: DragWidgetBuilderV2(
	isScreenshotDragWidget: true,
	builder: (index, child, screenshot) {
		return Image(screenshot);
	}
)
```

# Constructors
- `ReorderableGridView.builder`
- `ReorderableGridView.count`
- `ReorderableSliverGridView.count`

## custom reorderable
You can use `ReorderableWrapperWidget` to custom your reorderable.
Use `ReorderableWrapperWidget` as root. and it's descendants is ReorderableItemView[] list
- `ReorderableWrapperWidget(child: SomeCollection(children: ReorderableItemView))`

# Important
- the `placeholderBuilder` is not right when the list is very long, is not fixable for now. please see [issue 47](https://github.com/huhuang03/reorderable_grid_view/issues/47)
- can drag out of scope is not fixable for now, please see [issue 52](https://github.com/huhuang03/reorderable_grid_view/issues/52)

# TODO
## fix `placeholderBuilder` is not right when the list is very long
## fix `Overlay` can drag out of container issue.

# Other link project
If this project is not fit your meet, you can try those other projects
- [reorderables](https://github.com/hanshengchiu/reorderables)
- [reorderable_grid](https://github.com/casvanluijtelaar/reorderable_grid)
- [flutter-reorderable-grid-view](https://github.com/karvulf/flutter-reorderable-grid-view)
