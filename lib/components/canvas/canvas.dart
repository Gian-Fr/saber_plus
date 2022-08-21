
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:saber/components/canvas/interactive_canvas.dart';

import '_stroke.dart';
import 'inner_canvas.dart';

class Canvas extends StatelessWidget {
  const Canvas({
    Key? key,
    required this.path,
    required this.pageIndex,
    required this.innerCanvasKey,
    required this.undo,
    required this.redo,
    required this.strokes,
    required this.currentStroke,

    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.onPressureChanged,
  }) : super(key: key);

  static const double canvasWidth = 1000;
  static const double canvasHeight = canvasWidth * 1.4;

  final String path;
  final int pageIndex;

  final VoidCallback undo;
  final VoidCallback redo;

  final ValueChanged<ScaleStartDetails> onScaleStart;
  final ValueChanged<ScaleUpdateDetails> onScaleUpdate;
  final ValueChanged<ScaleEndDetails> onScaleEnd;
  final ValueChanged<double?> onPressureChanged;

  final Iterable<Stroke> strokes;
  final Stroke? currentStroke;

  final GlobalKey<State<InnerCanvas>>? innerCanvasKey;

  bool _isPointerDeviceAStylus(PointerDeviceKind kind) {
    return kind == PointerDeviceKind.stylus || kind == PointerDeviceKind.invertedStylus;
  }

  _listenerPointerEvent(PointerEvent event) {
    onPressureChanged(_isPointerDeviceAStylus(event.kind) ? event.pressure : null);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "inner-canvas-$path-page$pageIndex",
      
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Listener(
          onPointerDown: _listenerPointerEvent,
          onPointerMove: _listenerPointerEvent,
          child: GestureDetector(
            onSecondaryTapUp: (TapUpDetails details) => undo(),
            onTertiaryTapUp: (TapUpDetails details) => redo(),
            child: InteractiveCanvasViewer(
              panEnabled: false,
              maxScale: 5,
              clipBehavior: Clip.none,

              onDrawStart: onScaleStart,
              onDrawUpdate: onScaleUpdate,
              onDrawEnd: onScaleEnd,

              child: Center(
                child: FittedBox(
                  child: InnerCanvas(
                    key: innerCanvasKey,
                    width: canvasWidth,
                    height: canvasHeight,
                    strokes: strokes,
                    currentStroke: currentStroke,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
