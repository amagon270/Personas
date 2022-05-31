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

  // List<Point> points = EvenlySpacePoints(40);
  List<Point> points = RandomBlob(4, randomness: 0);

  static Rand(double min, double max) {
    return (Random().nextDouble() * (max - min)) + min;
  }

  static Vector placePoint({
    required int totalPoints, 
    required int pointNo, 
    required double pointOffset, 
    required double startOffset, 
    required double magnitude, 
    required double variation, 
    double? nudge
  }) {
    final randX = Rand(magnitude - magnitude*variation, magnitude + magnitude*variation);
    final mag = randX + (((nudge) ?? randX) - randX) * (1-variation*2) * (variation == 0 ? 0 : 1);
    
    return Vector(
      (0.5 + cos(pi*2*pointNo/totalPoints + pi*2*startOffset + pi*2*pointOffset/totalPoints) / 2 * mag).clamp(0, 1),
      (0.5 + sin(pi*2*pointNo/totalPoints + pi*2*startOffset + pi*2*pointOffset/totalPoints) / 2 * mag).clamp(0, 1)
    );
  }

  static List<Point> RandomBlob(int points, {double offset = 1/8, double splineScale = 0.5, scale = 0.85, double randomness = 0.1}) {
    final distribution = (splineScale - 0.5).abs();
    final smoothscale = 0.4525 - (1 - 1/pow(2, points-4))/10;
    List<Point> newPoints = [];
    for (int i = 0; i < points; i++) {
      Vector position = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 0, 
        startOffset: offset, 
        magnitude: scale, 
        variation: distribution + randomness
      );
      Vector c1 = Vector(0.5, 0.5);
      Vector c2 = Vector(0.5, 0.5);
      newPoints.add(Point(position, c1, c2));
    }
    for (int i = 0; i < points; i++) {
      newPoints[i].spline1 = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 1/3, 
        startOffset: offset, 
        magnitude: splineScale + smoothscale, 
        variation: distribution + randomness / 10, 
        nudge: newPoints[i].pos.Magnitude(offset: Vector(0.5, 0.5))*2
      );
      newPoints[i].spline2 = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 2/3, 
        startOffset: offset, 
        magnitude: splineScale + smoothscale, 
        variation: distribution  + randomness / 10, 
        nudge: newPoints[(i+1)%points].pos.Magnitude(offset: Vector(0.5, 0.5))*2
      );
    }
    return newPoints;
  }

  static List<Point> EvenlySpacePoints(int points, {double offset = 1/8, double splineScale = 0.5}) {
    final smoothscale = 0.4525 - (1 - 1/pow(2, points-4))/10;
    List<Point> newPoints = [];
    
    for (int i = 0; i < points; i++) {
      Vector position = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 0, 
        startOffset: offset, 
        magnitude: 0.85, 
        variation: 0
      );
      Vector c1 = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 1/3, 
        startOffset: offset, 
        magnitude: splineScale + smoothscale, 
        variation: 0
      );
      Vector c2 = placePoint(
        totalPoints: points, 
        pointNo: i, 
        pointOffset: 2/3, 
        startOffset: offset, 
        magnitude: splineScale + smoothscale, 
        variation: 0
      );
      newPoints.add(Point(position, c1, c2));
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
    points[point].spline2.x = c2x ?? points[point].spline2.x;
    points[point].spline2.y = c2y ?? points[point].spline2.y;

    return points[point];
  }

  @override
  void paint(Canvas canvas, Size size) {
    
    Paint paint0 = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0)
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
