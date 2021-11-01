// What will happen If I separate this two?
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_state.dart';

class ReorderableGridItem extends StatefulWidget {
  final Widget child;
  final Key key;
  final int index;
  final CapturedThemes capturedThemes;

  const ReorderableGridItem(
      {required this.child,
        required this.key,
        required this.index,
        required this.capturedThemes})
      : super(key: key);

  @override
  ReorderableGridItemState createState() => ReorderableGridItemState();
}


// Hello you can use the self or parent's size. to decide the new position.
class ReorderableGridItemState extends State<ReorderableGridItem>
    with TickerProviderStateMixin {
  late ReorderableGridViewState _listState;

  Key get key => widget.key;
  Widget get child => widget.child;

  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      this.setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  /// We can only check the items between startIndex and the targetIndex, but for simply, we check all <= targetDropIndex
  void updateForGap(int targetDropIndex) {
    // Actually I can use only use the targetDropIndex to decide the target pos, but what to do I change middle
    if (!mounted) return;
    // How can I calculate the target?

    // let's try use dragSize.
    Offset newOffset = _listState.getOffsetInDrag(this.index);
    if (newOffset != _targetOffset) {
      _targetOffset = newOffset;

      if (this._offsetAnimation == null) {
        this._offsetAnimation = AnimationController(vsync: _listState)
          ..duration = Duration(milliseconds: 250)
          ..addListener(rebuild)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _startOffset = _targetOffset;
              this._offsetAnimation?.dispose();
              this._offsetAnimation = null;
            }
          })
          ..forward(from: 0.0);
      } else {
        // 调转方向
        _startOffset = offset;
        this._offsetAnimation?.forward(from: 0.0);
      }
    }
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }

    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  // Ok, for now we use multiDragRecognizer
  MultiDragGestureRecognizer _createDragRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }

  @override
  void initState() {
    // why I need this??
    // Can I move this to another class??
    _listState = ReorderableGridViewState.of(context);
    _listState.registerItem(this);
    super.initState();
  }

  // ths is strange thing.
  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  // Ok, how can we calculate the _offsetAnimation
  AnimationController? _offsetAnimation;

  Offset get offset {
    if (_offsetAnimation != null) {
      return Offset.lerp(_startOffset, _targetOffset,
          Curves.easeInOut.transform(_offsetAnimation!.value))!;
    }
    return _targetOffset;
  }

  @override
  void dispose() {
    _listState.unRegisterItem(this.index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ReorderableGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState.unRegisterItem(oldWidget.index, this);
      _listState.registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      // _debug("pos $index is dragging.");
      return SizedBox();
    }

    Widget _buildChild(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (_dragging) {
            // why put you in the Listener??
            return SizedBox();
          }

          final _offset = offset;
          return Transform(
            // you are strange.
            transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
            child: child,
          );
        },
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent e) {
        // remember th pointer down??
        // _debug("onPointerDown at $index");
        var listState = ReorderableGridViewState.of(context);
        listState.startDragRecognizer(index, e, _createDragRecognizer());
      },
      child: _buildChild(child),
    );
  }

  void rebuild() {
    // _debug("rebuild called for index: ${this.index}, mounted: ${mounted}");
    if (mounted) {
      setState(() {});
    }
  }
}
