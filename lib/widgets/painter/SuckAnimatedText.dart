import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// Animated Text that displays a [Text] element with each character popping
/// like a stadium wave.
///
/// ![Wavy example](https://raw.githubusercontent.com/aagarwal1012/Animated-Text-Kit/master/display/wavy.gif)
class SuckAnimatedText extends AnimatedText {
  /// The [Duration] of the motion of each character
  ///
  /// By default it is set to 300 milliseconds.
  final Duration speed;

  SuckAnimatedText(
    String text, {
    TextAlign textAlign = TextAlign.start,
    TextStyle? textStyle,
    this.speed = const Duration(milliseconds: 300),
    this.target = const Offset(500, 200),
  }) : super(
          text: text,
          textAlign: textAlign,
          textStyle: textStyle,
          duration: speed,
        );

  final Offset target;

  late Animation<double> _waveAnim;

  @override
  void initAnimation(AnimationController controller) {
    _waveAnim = Tween<double>(begin: 0, end: 1)
        .animate(controller);
  }

  @override
  Widget completeText(BuildContext context) => Container();

  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    final defaultTextStyle = DefaultTextStyle.of(context).style;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;
    
    return RepaintBoundary(
      child: CustomPaint(
        painter: _WTextPainter(
          progress: _waveAnim.value,
          text: text,
          textStyle: defaultTextStyle.merge(textStyle),
          scaleFactor: scaleFactor,
          target: target
        ),
        child: Text(
          text,
          style: defaultTextStyle
              .merge(textStyle)
              .merge(TextStyle(color: Colors.transparent)),
          textScaleFactor: scaleFactor,
        ),
      ),
    );
  }
}

class _WTextPainter extends CustomPainter {
  _WTextPainter({
    required this.progress,
    required this.text,
    required this.textStyle,
    required this.scaleFactor,
    required this.target
  });

  final Offset target;
  final double progress, scaleFactor;
  final String text;
  // Private class to store text information
  _TextLayoutInfo? _textLayoutInfo;
  final TextStyle textStyle;

  double textY = 0;
  double textX = 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (_textLayoutInfo == null) {
      // calculate the initial position of each char
      calculateLayoutInfo(text);
    } else {
      canvas.save();
      final Offset centerOffset = Offset(size.width/2, size.height/2 - _textLayoutInfo!.height / 2);

      final p = math.min(progress, 1.0);
      // drawing the char
      drawText(
        canvas,
        _textLayoutInfo!.text,
        Offset(target.dx * math.sin(p*math.pi/2), target.dy * (1-(math.cos(p*math.pi/2)))) +
          centerOffset,
        _textLayoutInfo
      );

    canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_WTextPainter oldDelegate) {
    if (oldDelegate.progress != progress) {
      // calulate layout of text and movement of moving chars
      calculateLayoutInfo(text);
      calculateMove();
      return true;
    }
    return false;
  }

  void calculateMove() {
    if (_textLayoutInfo != null) {
      final height = _textLayoutInfo!.height;

      _textLayoutInfo!.isMoving = true;
      _textLayoutInfo!.riseHeight = progress * height;
    } else {
      calculateLayoutInfo(text);
    }
  }

  void drawText(Canvas canvas, String text, Offset offset,
      _TextLayoutInfo? textLayoutInfo) {
    var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      textScaleFactor: scaleFactor * (1 - progress.clamp(0, 1)),
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        offset.dx - textLayoutInfo!.width / 2,
        offset.dy + (textLayoutInfo.height - textPainter.height) / 2,
      ),
    );
  }

  void calculateLayoutInfo(String text) {
    // creating a textPainter to get data about location and offset for chars
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textScaleFactor: scaleFactor * (1 - progress.clamp(0, 1)),
    );

    textPainter.layout();

    // creating layout for each char
    final textLayoutInfo = _TextLayoutInfo(
      text: text,
      width: textPainter.width,
      height: textPainter.height,
      baseline: textPainter
          .computeDistanceToActualBaseline(TextBaseline.ideographic),
    );

    _textLayoutInfo = textLayoutInfo;
  }
}

class _TextLayoutInfo {
  final String text;
  final double width;
  final double height;
  final double baseline;
  late double riseHeight;
  bool isMoving = false;

  _TextLayoutInfo({
    required this.text,
    required this.width,
    required this.height,
    required this.baseline,
  });
}