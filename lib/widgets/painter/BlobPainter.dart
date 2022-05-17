import 'package:flutter/material.dart';

class Point {
  Point(this.x, this.y, this.c1x, this.c1y, this.c2x, this.c2y);

  double x;
  double y; 
  double c1x;
  double c1y; 
  double c2x; 
  double c2y;
}

class BlobPainter extends CustomPainter{
  static final smallStart = 0.18;
  static final bigStart = 0.82;

  bool showDots = false;

  List<Point> points = [
    Point(smallStart, smallStart, 0.5, 0.5, 0.5, 0.5), 
    Point(bigStart, smallStart, 0.5, 0.5, 0.5, 0.5), 
    Point(bigStart, bigStart, 0.5, 0.5, 0.5, 0.5), 
    Point(smallStart, bigStart, 0.5, 0.5, 0.5, 0.5)
  ];

  Point nudgePoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    points[point].x += x ?? 0;
    points[point].y += y ?? 0;
    points[point].c1x += c1x ?? 0;
    points[point].c1y += c1y ?? 0;
    points[point].c2x += c2x ?? 0;
    points[point].c2y += c2y ?? 0;

    return points[point];
  }

  Point setPoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    points[point].x = x ?? points[point].x;
    points[point].y = y ?? points[point].y;
    points[point].c1x = c1x ?? points[point].c1x;
    points[point].c1y = c1y ?? points[point].c1y;
    points[point].c2x = c2x ?? points[point].c2x;
    points[point].c2y = c2y ?? points[point].c2y;

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
    path0.moveTo(size.width*points[0].x,size.height*points[0].y);
    for (int i = 0; i < points.length; i++) {
      path0.cubicTo(size.width*points[i].c1x,size.height*points[i].c1y,size.width*points[i].c2x,size.height*points[i].c2y,size.width*points[(i+1)%points.length].x,size.height*points[(i+1)%points.length].y);
    }
    path0.close();

    canvas.drawPath(path0, paint0);

    if (showDots) {
      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(Offset(size.width*points[i].x, size.height*points[i].y), 3, paint2);
        canvas.drawCircle(Offset(size.width*points[i].c1x, size.height*points[i].c1y), 3, paint1);
        canvas.drawCircle(Offset(size.width*points[i].c2x, size.height*points[i].c2y), 3, paint1);
      }
      }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
}
