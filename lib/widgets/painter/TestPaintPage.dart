import 'package:flutter/material.dart';
import 'package:personas/widgets/painter/BlobPainter.dart';

class TestPaintPage extends StatefulWidget {
  TestPaintPage({Key? key}) : super(key: key);

  @override
  _TestPaintPage createState() => _TestPaintPage();
}

class _TestPaintPage extends State<TestPaintPage> {
  final painter = BlobPainter();

  List<Point> points = [
    Point(0.25, 0.25, 0.5, 0.5, 0.5, 0.5), 
    Point(0.75, 0.25, 0.5, 0.5, 0.5, 0.5), 
    Point(0.75, 0.75, 0.5, 0.5, 0.5, 0.5), 
    Point(0.25, 0.75, 0.5, 0.5, 0.5, 0.5)
  ];

  double roundness = 0.0;

  void setPoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    setState(() {
      points[point] = painter.setPoint(point, x: x, y: y, c1x: c1x, c1y: c1y, c2x: c2x, c2y: c2y);
    });
  }

  void setRoundness(double value) {
    setState(() {
      roundness = value;
    });
    double posMain = 0.5 + ((value % 1) / 2);
    double negMain = 0.5 - ((value % 1) / 2);
    double posCross = 0.5 + ((value % 1) * 0.15);
    double negCross = 0.5 - ((value % 1) * 0.15);
    points[0] = painter.setPoint(0, c1y: negMain, c2y: negMain, c1x: negCross, c2x: posCross);
    points[1] = painter.setPoint(1, c1x: posMain, c2x: posMain, c1y: negCross, c2y: posCross);
    points[2] = painter.setPoint(2, c1y: posMain, c2y: posMain, c1x: posCross, c2x: negCross);
    points[3] = painter.setPoint(3, c1x: negMain, c2x: negMain, c1y: posCross, c2y: negCross);
  }

  Widget SliderColumn(String title, double value, Function onPress) {
    return Column(
      children: [
        Text(title),
        Slider(
          value: value,
          onChanged: (value) { onPress(value); }
        ),
      ],
    );
  }

  Widget ButtonRow(int point, String title) {
    return Row(
      children: [
        Text(title),
        SliderColumn("x+", points[point].x, (value) => { setPoint(point, x: value) }),
        SliderColumn("y+", points[point].y, (value) => { setPoint(point, y: value) }),
        SliderColumn("c1x+", points[point].c1x, (value) => { setPoint(point, c1x: value) }),
        SliderColumn("c1y+", points[point].c1y, (value) => { setPoint(point, c1y: value) }),
        SliderColumn("c2x+", points[point].c2x, (value) => { setPoint(point, c2x: value) }),
        SliderColumn("c2y+", points[point].c2y, (value) => { setPoint(point, c2y: value) }),
      ],
    );
  }

  List<Widget> ButtonRows() {
    return [
      ButtonRow(0, "Point 1"),
      ButtonRow(1, "Point 2"),
      ButtonRow(2, "Point 3"),
      ButtonRow(3, "Point 4"),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom paint Demo'),
      ),
      body: Container(
        child: Column(
          children: [
            InkWell(
              child: Text("Toggle Dots"),
              onTap: () {painter.showDots = !painter.showDots; },
            ),
            SliderColumn("Roundness", roundness, (value) => { setRoundness(value)}),
            ...ButtonRows(),
            Center(
              child: CustomPaint(
                size: Size(400,400), 
                painter: painter,
              ),
            ),
          ],
        )
      ),
    );
  }
}