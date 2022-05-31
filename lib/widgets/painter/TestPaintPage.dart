import 'package:flutter/material.dart';
import 'package:personas/widgets/painter/BlobPainter.dart';
import 'package:personas/widgets/painter/SuckAnimatedText.dart';
import 'package:personas/widgets/painter/VectorMaths.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class TestPaintPage extends StatefulWidget {
  TestPaintPage({Key? key}) : super(key: key);

  @override
  _TestPaintPage createState() => _TestPaintPage();
}

class _TestPaintPage extends State<TestPaintPage> {
  final painter = BlobPainter();

  List<Point> points = [
    Point(Vector(0.25, 0.25), Vector(0.5, 0.5), Vector(0.5, 0.5)), 
    Point(Vector(0.75, 0.25), Vector(0.5, 0.5), Vector(0.5, 0.5)), 
    Point(Vector(0.75, 0.75), Vector(0.5, 0.5), Vector(0.5, 0.5)), 
    Point(Vector(0.25, 0.75), Vector(0.5, 0.5), Vector(0.5, 0.5))
  ];

  double roundness = 0.5;
  double randomness = 0;
  int noOfPoints = 4;

  void setPoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    setState(() {
      points[point] = painter.setPoint(point, x: x, y: y, c1x: c1x, c1y: c1y, c2x: c2x, c2y: c2y);
    });
  }

  void setRoundness(double value) {
    setState(() {
      roundness = value;
    });
    painter.points = BlobPainter.EvenlySpacePoints(noOfPoints, splineScale: value);
  }

   void setRandomness(double value) {
    setState(() {
      randomness = value;
    });
    painter.points = BlobPainter.RandomBlob(noOfPoints, splineScale: value, randomness: randomness);
  }


  void addPoint() {
    setState(() {
      noOfPoints++;
    });
    // painter.points = BlobPainter.EvenlySpacePoints(noOfPoints, splineScale: roundness);
    painter.points = BlobPainter.RandomBlob(noOfPoints, splineScale: roundness, randomness: randomness);
  }

  void removePoint() {
    setState(() {
      noOfPoints--;
    });
    // painter.points = BlobPainter.EvenlySpacePoints(noOfPoints, splineScale: roundness);
    painter.points = BlobPainter.RandomBlob(noOfPoints, splineScale: roundness, randomness: randomness);
  }

  void scalePointUp() {
    painter.ScaleSpline(1.1);
  }

  void scalePointDown() {
    painter.ScaleSpline(0.9);
  }

  Widget Button(String title, Function onPress) {
    return InkWell(
      onTap: () {onPress();},
      child: Container(
        color: Colors.amber,
        child: Text(title)
      ),
    );
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
        SliderColumn("x+", painter.points[point].pos.x, (value) => { setPoint(point, x: value) }),
        SliderColumn("y+", painter.points[point].pos.y, (value) => { setPoint(point, y: value) }),
        SliderColumn("c1x+", painter.points[point].spline1.x, (value) => { setPoint(point, c1x: value) }),
        SliderColumn("c1y+", painter.points[point].spline1.y, (value) => { setPoint(point, c1y: value) }),
        SliderColumn("c2x+", painter.points[point].spline2.x, (value) => { setPoint(point, c2x: value) }),
        SliderColumn("c2y+", painter.points[point].spline2.y, (value) => { setPoint(point, c2y: value) }),
      ],
    );
  }

  Widget TestText() {
    return (
      AnimatedTextKit(
        repeatForever: true,
        // isRepeatingAnimation: false,
        animatedTexts: [
          SuckAnimatedText('AMAZING', speed: Duration(milliseconds: 1000), target: Offset(-50, -200))
        ],
        onTap: () {
          print("Tap Event");
        },
      )
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
            Button("Toggle Dots", () { painter.showDots = !painter.showDots; }),
            SliderColumn("Roundness", roundness, (value) => { setRoundness(value) }),
            SliderColumn("Randomness", randomness, (value) => { setRandomness(value) }),
            Button("Points +", () { addPoint(); }),
            Button("Points -", () { removePoint(); }),
            Button("scale +", () { scalePointUp(); }),
            Button("scale -", () { scalePointDown(); }),
            ...ButtonRows(),
            Center(
              child: CustomPaint(
                size: Size(400,400), 
                painter: painter,
              ),
            ),
            TestText(),
          ],
        )
      ),
    );
  }
}