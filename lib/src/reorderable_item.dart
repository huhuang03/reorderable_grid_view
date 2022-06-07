import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_mixin.dart';
import 'package:reorderable_grid_view/src/util.dart';

/// A child wrapper.
class ReorderableItemView extends StatefulWidget {
  final Widget child;
  final Key key;
  final int index;

  const ReorderableItemView({
    required this.child,
    required this.key,
    required this.index,
  }) : super(key: key);

  static List<Widget> wrapMeList(List<Widget>? header, List<Widget> children,
      List<Widget>? footer) {
    var rst = <Widget>[];
    rst.addAll(header ?? []);
    for (var i = 0; i < children.length; i++) {
      var child = children[i];
      rst.add(ReorderableItemView(
        child: child,
        key: child.key!,
        index: i,
      ));
    }

    rst.addAll(footer ?? []);
    return rst;
  }

  @override
  ReorderableItemViewState createState() => ReorderableItemViewState();
}

class ReorderableItemViewState extends State<ReorderableItemView> with TickerProviderStateMixin {
  late ReorderableGridStateMixin _listState;
  bool _dragging = false;
  // ths is strange thing.
  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  // Ok, how can we calculate the _offsetAnimation
  AnimationController? _offsetAnimation;
  Offset _placeholderOffset = Offset.zero;

  Key get key => widget.key;

  Widget get child => widget.child;

  int get index => widget.index;

  set dragging(bool dragging) {
    if (mounted) {
      this.setState(() {
        _dragging = dragging;
      });
    }
  }


  /// We can only check the items between startIndex and the targetIndex, but for simply, we check all <= targetDropIndex
  void updateForGap(int dropIndex) {
    // Actually I can use only use the targetDropIndex to decide the target pos, but what to do I change middle
    if (!mounted) return;
    // How can I calculate the target?
    _checkPlaceHolder();

    if (_dragging) {
      debug("updateForGap $dropIndex");
      return;
    }

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

  void _checkPlaceHolder() {
    if (!_dragging) {
      return;
    }

    final _selfPos = index;
    final _targetPos = _listState.dropIndex;
    if (_targetPos < 0) {
      // not dragging?
      return;
    }

    if (_selfPos == _targetPos) {
      setState(() {
        _placeholderOffset = Offset.zero;
      });
    }

    if (_selfPos != _targetPos) {
      // any better idea?
      setState(() {
        debug("_buildPlaceHolder for index $index, _offset: $_placeholderOffset, _targetPos: $_targetPos");
        _placeholderOffset = _listState.getPos(_targetPos) - _listState.getPos(_selfPos);
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
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }

  @override
  void initState() {
    _listState = ReorderableGridStateMixin.of(context);
    _listState.registerItem(this);
    super.initState();
  }

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
  void didUpdateWidget(covariant ReorderableItemView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState.unRegisterItem(oldWidget.index, this);
      _listState.registerItem(this);
    }
  }

  Widget _buildPlaceHolder() {
    // why you are not right?
    debug("placeholderBuilder: ${_listState.placeholderBuilder}");
    if (_listState.placeholderBuilder == null) {
      return SizedBox();
    }

    return Transform(
      transform: Matrix4.translationValues(_placeholderOffset.dx, _placeholderOffset.dy, 0),
      child: _listState.placeholderBuilder!(index, _listState.dropIndex, child),
    );
  }

  // how do you think of this?
  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      return _buildPlaceHolder();
    }

    Widget _buildChild(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (_dragging) {
            return _buildPlaceHolder();
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
        var listState = ReorderableGridStateMixin.of(context);
        listState.startDragRecognizer(index, e, _createDragRecognizer());
      },
      child: _buildChild(child),
    );
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}
