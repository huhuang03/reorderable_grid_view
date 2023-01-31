## [2.2.6-alpha.13] = 2023-1-30
- fix `Overlay.of(context)` and `Scrollable.of(context)` return option and not option in different flutter version.

## [2.2.6-alpha.13] = 2023-1-30
- add option `restrictDragScope`, restrict drag scope to ReorderableGridView, not drag over the scree, default is false.

## [2.2.6-alpha.12] = 2023-1-29
- fix bug #52. How to restrict dragging of widget inside a specific container or a prarent container & not allow dragging all over the phone screen ?
But not fix in ReorderableGridView, not ReorderableSliverGridView

## [2.2.6-alpha.11] = 2023-1-11
- add DragWidgetBuilderV2

## [2.2.6-alpha.10] = 2023-1-10
- revert change in 2.2.6-alpha.9

## [2.2.6-alpha.9] = 2023-1-10
- fix pageView save state issue, recoding to https://stackoverflow.com/questions/45944777/losing-widget-state-when-switching-pages-in-a-flutter-pageview
 
## [2.2.6-alpha.8] = 2023-1-10
- decide use child as DragWidget because use screenshot will show a blank widget first.

## [2.2.6-alpha.7] = 2023-1-9
- fix bug https://github.com/huhuang03/reorderable_grid_view/pull/58, fix item rebuild when drag issue
- use Image(widget screenshot) as drag view.

## [2.2.6-alpha.6] = 2023-1-7
- remove unused log
- update demo_reorderable_count, add remove and add method.
 
## [2.2.6-alpha.5] = 2022-12-14
- Expose onDragUpdate callback. https://github.com/huhuang03/reorderable_grid_view/pull/56

## [2.2.6-alpha.4] = 2022-12-13
- revert 2.2.6-alpha.3 because it intro a new issue. https://github.com/huhuang03/reorderable_grid_view/issues/54.
 
## [2.2.6-alpha.3] - 2022-12-3
- fix can drag over whole screen issue. https://github.com/huhuang03/reorderable_grid_view/issues/52.
- fix sliver update for gap child is null issue.
 
## [2.2.6-alpha.2] - 2022-11-1
- fix drag info pos in nested navigator. https://github.com/huhuang03/reorderable_grid_view/issues/49

## [2.2.6-alpha.1] - 2022-10-30
- add ReorderableSliverGridView option header and footer. https://github.com/huhuang03/reorderable_grid_view/issues/49
 
## [2.2.5] - 2022-9-8
- https://github.com/huhuang03/reorderable_grid_view/pull/43

## [2.2.4] - 2022-8-17
- release 2.2.4

## [2.2.3-alpha.5] - 2022-7-4
- fix reorderable item find next/previous pos.

## [2.2.3-alpha.4] - 2022-7-4
- add option `mainAxisExtent` by https://github.com/huhuang03/reorderable_grid_view/pull/36
- add option `dragStartDelay ` by https://github.com/huhuang03/reorderable_grid_view/pull/35
- add option `placeholder` by https://github.com/huhuang03/reorderable_grid_view/pull/28
 
## [2.2.3-alpha.3] - 2022-6-7
- add option `header` `in Reorderable.count`, and please notice header and footer is only support
`Reorderable.count`

## [2.2.3-alpha.2] - 2022-5-30
- add OnDragStart

## [2.2.3-alpha.1] - 2022-5-9
- add placeholderBuilder

## [2.2.2] - 2021-12-29
- fix bug 24.
## [2.2.1] - 2021-11-24
- seems like 2.2.0 forgot some thing?

## [2.2.0] - 2021-11-24
- remove the unnecessary `crossAxisSpacing` staff.

## [2.1.0-alpha.1] - 2021-11-4
- add ReorderableSliverGridView.count.

## [1.2.0-alpha.1] - 2021-9-25
- look like the official MultiDragGestureRecognizer api has changed after(maybe earlier) flutter 2.5.1

## [1.1.0] - 2021-8-2
- 1.1.0-alpha.4 is ok, release version.

## [1.1.0-alpha.4] - 2021-7-28
- support alpha.3. For the merge mistake.

## [1.1.0-alpha.3] - 2021-7-27
- update dragWidgetBuilder(child) to dragWidgetBuilder(index, child)

## [1.1.0-alpha.2] - 2021-7-27
- add option dragWidgetBuilder, can config custom drag widget.
- add option scrollSpeedController, can config the scroll speed.

## [1.1.0-alpha.1] - 2021-7-26
- fix childAspectRatio bug

## [1.1.0-alpha] - 2021-7-25
- use new impl correspond to new reorderable_listview impl
- add drag scroll ability
- deprecate option antiMultiDrag

## [1.0.0] - 2021-6-25
- add null-safety
- add option antiMultiDrag

## [0.0.2+2] - 2021-4-14
- add GridView construct params, like physics etc.

## [0.0.2+1] - 2021-02-04
fix add footer issue

## [0.0.2] - 2021-02-04
fix grid gap, calculate item position issue.

## [0.0.1] - TODO: Add release date.

* TODO: Describe initial release.
