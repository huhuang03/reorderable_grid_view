
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_mixin.dart';
import 'package:reorderable_grid_view/src/util.dart';

/// A child wrapper.
class ReorderableItemView extends StatefulWidget {
  const ReorderableItemView({
    required Key key,
    required this.child,
    required this.index,
    this.indexInAll,
  }) : super(key: key);

  final Widget child;
  final int index;
  // not good!!
  final int? indexInAll;

  static List<Widget> wrapMeList(
    List<Widget>? header,
    List<Widget> children,
    List<Widget>? footer,
  ) {
    var rst = <Widget>[];
    rst.addAll(header ?? []);
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      assert(() {
        if (child.key == null) {
          throw FlutterError(
            'Every item of ReorderableGridView must have a key.',
          );
        }
        return true;
      }());
      rst.add(ReorderableItemView(
        key: child.key!,
        index: i,
        indexInAll: i + (header?.length?? 0),
        child: child,
      ));
    }

    rst.addAll(footer ?? []);
    return rst;
  }

  @override
  State<ReorderableItemView> createState() => ReorderableItemViewState();
}

class ReorderableItemViewState extends State<ReorderableItemView>
    with TickerProviderStateMixin {
  late ReorderableGridStateMixin _listState;
  bool _dragging = false;
  final screenshotKey = GlobalKey();

  // ths is strange thing.
  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;

  // Ok, how can we calculate the _offsetAnimation
  AnimationController? _offsetAnimation;
  Offset _placeholderOffset = Offset.zero;

  Key get key => widget.key!;

  Widget get child => widget.child;

  /// This is the index in [ReorderableItem]
  int get index => widget.index;

  /// This is the index in [AllChild]
  int? get indexInAll => widget.indexInAll;

  final Key childKey = GlobalKey();

  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  Offset getRelativePos(Offset dragPosition) {
    final parentRenderBox = _listState.context.findRenderObject() as RenderBox;
    final parentOffset = parentRenderBox.localToGlobal(dragPosition);

    final renderBox = context.findRenderObject() as RenderBox;
    return renderBox.localToGlobal(parentOffset);
  }

  RenderBox get parentRenderBox {
    return _listState.context.findRenderObject() as RenderBox;
  }

  /// We can only check the items between startIndex and the targetIndex,
  /// but for simply, we check all <= targetDropIndex
  void updateForGap(int dropIndex) {
    // Actually I can use only use the targetDropIndex to decide the target pos, but what to do I change middle
    if (!mounted) return;
    // we don't need update if already dispose()
    if (!_listState.containsByIndex(index)) {
      return;
    }
    // How can I calculate the target?
    _checkPlaceHolder();

    if (_dragging) {
      return;
    }

    // debug("called getOffsetInDrag index $index");
    // let's try use dragSize.
    Offset newOffset = _listState.getOffsetInDrag(index);
    if (newOffset != _targetOffset) {
      _targetOffset = newOffset;

      if (_offsetAnimation == null) {
        _offsetAnimation = AnimationController(vsync: _listState)
          ..duration = const Duration(milliseconds: 250)
          ..addListener(rebuild)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _startOffset = _targetOffset;
              _offsetAnimation?.dispose();
              _offsetAnimation = null;
            }
          })
          ..forward(from: 0.0);
      } else {
        // 调转方向
        _startOffset = offset;
        _offsetAnimation?.forward(from: 0.0);
      }
    }
  }

  void _checkPlaceHolder() {
    if (!_dragging) {
      return;
    }

    final selfPos = index;
    final targetPos = _listState.dropIndex;
    if (targetPos < 0) {
      // not dragging?
      return;
    }

    if (selfPos == targetPos) {
      setState(() {
        _placeholderOffset = Offset.zero;
      });
    }

    if (selfPos != targetPos) {
      // any better idea?
      setState(() {
        debug(
            "_buildPlaceHolder for index $index, _offset: $_placeholderOffset, _targetPos: $targetPos");
        _placeholderOffset = _listState.getPosByIndex(targetPos) -
            _listState.getPosByIndex(selfPos);
      });
    }
  }

  void resetGap() {
    setState(() {
      if (_offsetAnimation != null) {
        _offsetAnimation!.dispose();
        _offsetAnimation = null;
      }

      _startOffset = Offset.zero;
      _targetOffset = Offset.zero;
      _placeholderOffset = Offset.zero;
    });
  }

  // Ok, for now we use multiDragRecognizer
  MultiDragGestureRecognizer _createDragRecognizer() {
    final dragStartDelay = _listState.dragStartDelay;
    if (dragStartDelay.inMilliseconds == 0) {
      return ImmediateMultiDragGestureRecognizer(debugOwner: this);
    }
    return DelayedMultiDragGestureRecognizer(
      debugOwner: this,
      delay: dragStartDelay,
    );
  }

  @override
  void initState() {
    _listState = ReorderableGridStateMixin.of(context);
    _listState.registerItem(this);
    super.initState();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      return Offset.lerp(
        _startOffset,
        _targetOffset,
        Curves.easeInOut.transform(_offsetAnimation!.value),
      )!;
    }

    return _targetOffset;
  }

  @override
  void dispose() {
    _listState.unRegisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReorderableItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState.unRegisterItem(oldWidget.index, this);
      _listState.registerItem(this);
    }
  }

  Widget _buildPlaceHolder() {
    // why you are not right?
    if (_listState.placeholderBuilder == null) {
      return Container(
        color: Colors.amber,
        child: const SizedBox());
    }

    return Transform(
      transform: Matrix4.translationValues(
          _placeholderOffset.dx, _placeholderOffset.dy, 0),
      child: _listState.placeholderBuilder!(index, _listState.dropIndex, child),
    );
  }

  // how do you think of this?
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Listener(
        onPointerDown: (PointerDownEvent e) {
          var listState = ReorderableGridStateMixin.of(context);
          if (_listState.dragEnabled) {
            listState.startDragRecognizer(index, e, _createDragRecognizer());
          }
        },
        child: LayoutBuilder(
          builder: (context, constraint) {
            return Transform(
              transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
              child: Stack(
                children: [
                  Offstage(
                    offstage: !_dragging,
                    child: Container(
                      constraints: constraint,
                      child: _buildPlaceHolder()),
                  ),
                  Offstage(
                    offstage: _dragging,
                    child: Container(
                      constraints: constraint,
                      child: child,
                    ),
                  )
                ],
              ),
            );
          },
        )
        // child: buildChild(child),
      ),
    );
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}
