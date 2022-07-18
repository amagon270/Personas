import 'dart:math';

import 'package:flutter/material.dart';
import 'package:personas/widgets/painter/BlobPainter.dart';
import 'package:personas/widgets/painter/SuckAnimatedText.dart';
import 'package:personas/widgets/painter/VectorMaths.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:hexagon/hexagon.dart';

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
  bool isAnimating = false;

  //hexagon
  double scale = 0.5;
  double colourRoation = 0;
  double colourScaleOffset = 0;
  double lightnessOffset = 0.7;
  double saturation = 1;

  void setHexagonParams({double? s, double? r, double? o, double? l, double? sat}) {
    setState(() {
      scale = s ?? scale;
      colourRoation = r ?? colourRoation;
      colourScaleOffset = o ?? colourScaleOffset;
      lightnessOffset = l ?? lightnessOffset;
      saturation = sat ?? saturation;
    });
  }

  void setPoint(int point, {double? x, double? y, double? c1x, double? c1y, double? c2x, double? c2y}) {
    setState(() {
      points[point] = painter.setPoint(point, x: x, y: y, c1x: c1x, c1y: c1y, c2x: c2x, c2y: c2y);
    });
  }

  void setRoundness(double value) {
    setState(() {
      roundness = value;
    });
    painter.points = BlobPainter.RandomBlob(noOfPoints, splineScale: value, randomness: randomness);
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

  void toggleAnimation() {
    setState(() {
      isAnimating = !isAnimating;
    });
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
    if (isAnimating) {
      return (
        AnimatedTextKit(
          // repeatForever: true,
          // pause: Duration(seconds: 5),
          isRepeatingAnimation: false,
          animatedTexts: [
            SuckAnimatedText('AMAZING', speed: Duration(milliseconds: 1000), target: Offset(0, -400), textStyle: TextStyle(fontSize: 60))
          ],
        )
      );
    }
    return Text("AMAZING");
  }

  Widget ButtonRows() {
    List<Widget> sliders = [];
    for (int i = 0; i < painter.points.length; i++) {
      sliders.add(ButtonRow(i, "Point $i"));
    }
    return Container(
      height: 500,
      child: ListView.builder(
        itemCount: sliders.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (BuildContext context, int index) {
          return (sliders[index]);
        }
      )
    );
  }

  Widget GreyscaleHexagon() {
    int cols = 5;
    int rows = 1;
    return Container(
      width: 200,
      height: 100,
      child: InteractiveViewer(
        minScale: 0.2,
        maxScale: 4.0,
        child: HexagonOffsetGrid.oddPointy(
          columns: cols,
          rows: rows,
          buildTile: (col, row) {
            double lightness = ((col*2 + row)/((cols-1)*2 + rows-1));
            // print(col.toString() + row.toString());
            return HexagonWidgetBuilder(
              color: HSLColor.fromAHSL(1, 0, 0, lightness).toColor(),
              child: InkWell(
                onTap: () {
                  // print("$coordinates, $xAngle, $yAngle, $zAngle");
                  // print(degrees);
                },
              )
            );
          },
        ),
      ),
    );
  }

  Widget TestHexagonGrid() {
    int colorWheelDepth = 6;

    return Container(
      width: 500,
      height: 500,
      child: InteractiveViewer(
        minScale: 0.2,
        maxScale: 4.0,
        child: HexagonGrid(
          hexType: HexagonType.FLAT,
          depth: colorWheelDepth,
          buildTile: (coordinates) {
            double hue = 1;
            double lightness = 1;
            if (coordinates.z == colorWheelDepth && false) {
              lightness = (-coordinates.y)/colorWheelDepth;
              saturation = 0;
            } else {
            List<double> allAngles = [];
            for (int i = 0; i < coordinates.x.abs(); i++) {
              if (coordinates.x > 0) allAngles.add(pi/6);
              if (coordinates.x < 0) allAngles.add(-pi*5/6);
            }
            for (int i = 0; i < coordinates.y.abs(); i++) {
              if (coordinates.y > 0) allAngles.add(pi*5/6);
              if (coordinates.y < 0) allAngles.add(-pi/6);
            }
            for (int i = 0; i < coordinates.z.abs(); i++) {
              if (coordinates.z > 0) allAngles.add(-pi/2);
              if (coordinates.z < 0) allAngles.add(pi/2);
            }
            double sins = 0;
            double coss = 0;
            for (int i = 0; i < allAngles.length; i++) {
              sins += sin(allAngles[i]);
              coss += cos(allAngles[i]);
            }
            double angle = (-atan2(sins, coss) - pi/3) % (pi*2);
            double distance = 1 - (sqrt(pow(sins, 2) + pow(coss, 2)) / (sqrt(3)*colorWheelDepth));

            final double rescaleFactor = 360/pow(360, scale);

            double degrees = (angle/pi*180 + colourRoation) % 360;

            double newRange = ((pow(degrees, scale)*rescaleFactor) + colourScaleOffset) % 360;

            hue = newRange;
            lightness = distance*lightnessOffset + (1-lightnessOffset);
            }

            return HexagonWidgetBuilder(
              color: HSLColor.fromAHSL(1, hue, saturation, lightness).toColor(),
              child: InkWell(
                onTap: () {
                  print("$coordinates");
                },
              )
            );
          },
        ),
      ),
    );
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
            // Button("Toggle Dots", () { painter.showDots = !painter.showDots; }),
            // SliderColumn("Roundness", roundness, (value) => { setRoundness(value) }),
            // SliderColumn("Randomness", randomness, (value) => { setRandomness(value) }),
            // Button("Points +", () { addPoint(); }),
            // Button("Points -", () { removePoint(); }),
            // Button("scale +", () { scalePointUp(); }),
            // Button("scale -", () { scalePointDown(); }),
            // ButtonRows(),
            Center(
              child: CustomPaint(
                size: Size(400,400), 
                painter: painter,
              ),
            ),
            Container(height: 200,),
            Button("animate", () { toggleAnimation(); }),
            TestText(),
            // Row(children: [
            //   SliderColumn("scale", scale, (value) => { setHexagonParams(s: value)}),
            //   SliderColumn("rotation", colourRoation/360, (value) => { setHexagonParams(r: value*360)}),
            //   SliderColumn("offset", colourScaleOffset/360, (value) => { setHexagonParams(o: value*360)}),
            //   SliderColumn("Lightness", lightnessOffset, (value) => { setHexagonParams(l: value)}),
            //   SliderColumn("Saturation", saturation, (value) => { setHexagonParams(sat: value)}),
            // ],),
            
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //   TestHexagonGrid(),
              
            // ],),
            // GreyscaleHexagon(),
            
          ],
        )
      ),
    );
  }
}