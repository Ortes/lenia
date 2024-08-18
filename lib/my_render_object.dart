import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class LeniaAnimationWidget extends StatefulWidget {
  const LeniaAnimationWidget({super.key, required this.shader});

  final ui.FragmentShader shader;

  @override
  State<LeniaAnimationWidget> createState() => _LeniaAnimationWidgetState();
}

final shadeKey = GlobalKey();

class _LeniaAnimationWidgetState extends State<LeniaAnimationWidget> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _time = 0.0;
  Offset? point;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_handleTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleTick(Duration elapsed) {
    setState(() {
      final currentTime = elapsed.inMicroseconds.toDouble() / Duration.microsecondsPerSecond;
      if (currentTime - _time > 0.1) {
        _time = currentTime;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SizedBox(
          width: 250,
          height: 250,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              setState(() {
                point = event.localPosition;
              });
            },
            onPointerUp: (event) => setState(() {
              point = null;
            }),
            onPointerMove: (event) {
              setState(() {
                point = event.localPosition;
              });
            },
            child: MyRenderObjectWidget(
              key: shadeKey,
              time: _time,
              pointToDraw: point,
              shader: widget.shader,
            ),
          ),
        ),
      ),
    );
  }
}

class MyRenderObjectWidget extends LeafRenderObjectWidget {
  const MyRenderObjectWidget({
    super.key,
    required this.time,
    required this.pointToDraw,
    required this.shader,
  });

  final double time;
  final Offset? pointToDraw;
  final ui.FragmentShader shader;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MyRenderObject(
      shader: shader,
      devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
    );
  }

  @override
  void updateRenderObject(BuildContext context, covariant MyRenderObject renderObject) {
    renderObject.time = time;
    renderObject.pointToDraw = pointToDraw;
  }
}

class MyRenderObject extends RenderRepaintBoundary {
  MyRenderObject({
    required ui.FragmentShader shader,
    required devicePixelRatio,
  }) : _shader = shader;

  ui.FragmentShader get shader => _shader;
  ui.FragmentShader _shader;

  set shader(ui.FragmentShader value) {
    if (value == shader) {
      return;
    }
    _shader = value;
    markNeedsPaint();
  }

  double get time => _time;
  double _time = 0.0;

  set time(double value) {
    if (value == time) {
      return;
    }
    _time = value;
    markNeedsPaint();
  }

  double get devicePixelRatio => _devicePixelRatio;
  double _devicePixelRatio = 1.0;

  set devicePixelRatio(double value) {
    if (value == devicePixelRatio) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  Offset? get pointToDraw => _pointToDraw;
  Offset? _pointToDraw;

  set pointToDraw(Offset? value) {
    if (value == pointToDraw) {
      return;
    }
    _pointToDraw = value;
    markNeedsPaint();
  }

  ui.Image? _image;

  ui.Image get image => _image!;

  @override
  void performLayout() {
    size = constraints.biggest;
  }

  Future<void> saveImage() async {
    await Future.delayed(Duration.zero);
    _image = (layer! as OffsetLayer).toImageSync(Offset.zero & size, pixelRatio: devicePixelRatio);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final paint = Paint();
    if (_image == null) {
      paint
        ..color = Colors.black
        ..style = PaintingStyle.fill;
    } else {
      _shader
        ..setFloat(0, size.width)
        ..setFloat(1, size.height)
        ..setFloat(2, _time)
        ..setImageSampler(0, _image!);
      paint.shader = shader;
    }
    canvas.drawRect(offset & size, paint);
    if (pointToDraw != null) {
      final circlePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pointToDraw!, 20, circlePaint);
    }
    saveImage();
  }

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get isRepaintBoundary => true;
}
