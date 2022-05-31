import 'dart:math';
import 'VectorMaths.dart';
import 'package:flutter/material.dart';

class Point {
  Point(this.pos, this.spline1, this.spline2);

  Vector pos;
  Vector spline1;
  Vector spline2;
}

class BlobPainter extends CustomPainter{
  static final smallStart = 0.18;
  static final bigStart = 0.82;

  bool showDots = false;

  List<Point> points = EvenlySpacePoints(4);

  static Rand(double min, double max) {
    print((Random().nextDouble() * (max - min)) + min);
    return (Random().nextDouble() * (max - min)) + min;
  }

  static List<Point> RandomBlob(int points, {double offset = 5/4, double splineScale = 0.2}) {
    List<Point> newPoints = [];
    final double mainMin = 2;
    final double mainMax = 2.5;
    final double crossMin = splineScale * 0.75;
    final double crossMax = splineScale * 1.5;
    for (int i = 0; i < points; i++) {
      final pos = i/points*2*pi;
      final posRand = Rand(mainMin, mainMax);
      final spline1Rand = Rand(crossMin,crossMax);
      final spline2Rand = Rand(crossMin,crossMax);
      double x = (0.5 + cos(pos + pi*offset)/posRand).clamp(0, 1);
      double y = (0.5 + sin(pos + pi*offset)/posRand).clamp(0, 1);
      double c1x = (0.5 + cos(pos + pi*offset + pi*2/points/3)*spline1Rand).clamp(0, 1);
      double c1y = (0.5 + sin(pos + pi*offset + pi*2/points/3)*spline1Rand).clamp(0, 1);
      double c2x = (0.5 + cos(pos + pi*offset + pi*4/points/3)*spline2Rand).clamp(0, 1);
      double c2y = (0.5 + sin(pos + pi*offset + pi*4/points/3)*spline2Rand).clamp(0, 1);
      newPoints.add(Point(Vector(x,y), Vector(c1x,c1y), Vector(c2x,c2y)));
    }
    return newPoints;
  }

  static List<Point> EvenlySpacePoints(int points, {double offset = 5/4, double splineScale = 0.2}) {
    List<Point> newPoints = [];
    
    for (int i = 0; i < points; i++) {
      final pos = i/points*2*pi;
      double x = 0.5 + cos(pos + pi*offset)/2.2;
      double y = 0.5 + sin(pos + pi*offset)/2.2;
      double c1x = (0.5 + cos(pos + pi*offset + pi*2/points/3)*splineScale).clamp(0, 1);
      double c1y = (0.5 + sin(pos + pi*offset + pi*2/points/3)*splineScale).clamp(0, 1);
      double c2x = (0.5 + cos(pos + pi*offset + pi*4/points/3)*splineScale).clamp(0, 1);
      double c2y = (0.5 + sin(pos + pi*offset + pi*4/points/3)*splineScale).clamp(0, 1);
      newPoints.add(Point(Vector(x,y), Vector(c1x,c1y), Vector(c2x,c2y)));
    }
    return newPoints;
  }

  static CenterPoint(Point point) {
    point.pos.x -= 0.5;
    point.pos.y -= 0.5;
    point.spline1.x -= 0.5;
    point.spline1.y -= 0.5;
    point.spline2.x -= 0.5;
    point.spline2.y -= 0.5;
  }

  static AlignPoint(Point point) {
    point.pos.x += 0.5;
    point.pos.y += 0.5;
    point.spline1.x += 0.5;
    point.spline1.y += 0.5;
    point.spline2.x += 0.5;
    point.spline2.y += 0.5;
  }

  ScaleSpline(double scale) {
    points.forEach((point) {
      CenterPoint(point);
      point.spline1.Scale(scale);
      point.spline2.Scale(scale);
      AlignPoint(point);
    });
  }

  Point nudgePoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    points[point].pos.x += x ?? 0;
    points[point].pos.y += y ?? 0;
    points[point].spline1.x += c1x ?? 0;
    points[point].spline1.y += c1y ?? 0;
    points[point].spline2.x += c2x ?? 0;
    points[point].spline2.y += c2y ?? 0;

    return points[point];
  }

  Point setPoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    points[point].pos.x = x ?? points[point].pos.x;
    points[point].pos.y = y ?? points[point].pos.y;
    points[point].spline1.x = c1x ?? points[point].spline1.x;
    points[point].spline1.y = c1y ?? points[point].spline1.y;
    points[point].spline2.x = c2x ?? points[point].spline1.x;
    points[point].spline2.y = c2y ?? points[point].spline1.y;

    return points[point];
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    Paint paint0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.fill
      ..strokeWidth = 15;

    Paint paint1 = Paint()
      ..color = const Color.fromARGB(255, 233, 150, 13);

    Paint paint2 = Paint()
      ..color = const Color.fromARGB(255, 233, 10, 13);
         
    Path path0 = Path();
    path0.moveTo(size.width*points[0].pos.x,size.height*points[0].pos.y);
    for (int i = 0; i < points.length; i++) {
      path0.cubicTo(size.width*points[i].spline1.x,size.height*points[i].spline1.y,size.width*points[i].spline2.x,size.height*points[i].spline2.y,size.width*points[(i+1)%points.length].pos.x,size.height*points[(i+1)%points.length].pos.y);
    }
    path0.close();

    canvas.drawPath(path0, paint0);

    if (showDots) {
      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(Offset(size.width*points[i].pos.x, size.height*points[i].pos.y), 3, paint2);
        canvas.drawCircle(Offset(size.width*points[i].spline1.x, size.height*points[i].spline1.y), 3, paint1);
        canvas.drawCircle(Offset(size.width*points[i].spline2.x, size.height*points[i].spline2.y), 3, paint1);
      }
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}
