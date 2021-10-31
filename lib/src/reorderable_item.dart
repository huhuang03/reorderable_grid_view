


import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:reorderable_grid_view/src/reorderable_grid_builder.dart';

class ReorderableGridItem extends StatefulWidget {
  final Widget child;

  final int index;
  final CapturedThemes capturedThemes;

  const ReorderableGridItem({
    Key? key,
    required this.child,
    required this.index,
    required this.capturedThemes,
  }) : super(key: key);

  @override
  ReorderableGridItemState createState() => ReorderableGridItemState();
}

class ReorderableGridItemState extends State<ReorderableGridItem>
    with TickerProviderStateMixin {
      
  late ReorderableGridBuilderState _listState;

  Widget get child => widget.child;

  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  void updateForGap(int targetDropIndex) {
    if (!mounted) return;

    final newOffset = _listState.getOffsetInDrag(index);

    if (newOffset == _targetOffset) return;

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
      _startOffset = offset;
      _offsetAnimation?.forward(from: 0.0);
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

  MultiDragGestureRecognizer _createDragRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }

  @override
  void initState() {
    _listState = ReorderableGridBuilderState.of(context);
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
    _listState.unRegisterItem(index, this);
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
      return const SizedBox();
    }

    Widget _buildChild(Widget child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (_dragging) {
            return const SizedBox();
          }

          final _offset = offset;
          return Transform(
            transform: Matrix4.translationValues(_offset.dx, _offset.dy, 0),
            child: child,
          );
        },
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent e) {
        var listState = ReorderableGridBuilderState.of(context);
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



