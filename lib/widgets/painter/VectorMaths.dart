import 'dart:math';

class Vector {
  Vector(this.x, this.y, {this.scale = 0.5, this.random});

  double x;
  double y; 

  double scale;
  double? random;

  Vector Normalized() {
    final scale = sqrt(pow(x, 2) + pow(y, 2));
    return Vector(x/scale, y/scale);
  }

  Scale(double scale) {
    final scaled = Matrix2x2.scale(scale).DotProduct(Matrix.values([[x], [y]]));
    this.scale *= scale;
    this.x = scaled.values[0][0];
    this.y = scaled.values[1][0];
  }

  double Magnitude({Vector? offset}) {
    final x = this.x - (offset?.x ?? 0);
    final y = this.y - (offset?.y ?? 0);
    return sqrt(pow(x, 2) + pow(y, 2));
  }
}

class Matrix {
  late int width;
  late int height;
  late List<List<double>> values;

  Matrix(): width = 2, height = 2, values = [[1, 1], [1, 1]];

  Matrix.values(this.values): 
    width = values[0].length,
    height = values.length;

  Matrix.size(int w, int h) {
    this.values = List.generate(h, (index) => List.generate(w, (index) => 0));
    this.width = w;
    this.height = h;
  }

  Matrix DotProduct(Matrix other) {
    if (
      values.every((element) => element.length == width) &&
      other.values.every((element) => element.length == other.width) && 
      width == other.height
    ) {
      Matrix newMatrix = Matrix.size(other.width, height);
      for (int i = 0; i < other.width; i++) {
        for (int j = 0; j < height; j++) {
          for (int k = 0; k < width; k++) {
            newMatrix.values[j][i] += values[j][k] * other.values[k][i];
          }
        }
      }
      return newMatrix;
    }
    throw Error();
  }
}

class Matrix2x2 extends Matrix {
  late List<List<double>> values;

  Matrix2x2(double tl, double tr, double bl, double br) {
    this.values = [[tl, tr], [bl, br]];
  }

  Matrix2x2.scale(double scaleX, {double? scaleY}) {
    this.values = [[scaleX, 0], [0, scaleY ?? scaleX]];
  }

  Matrix2x2.rotateDegree(double angle) {
    final radians = angle/180*pi;
    this.values = [[cos(radians), sin(radians)], [-sin(radians), cos(radians)]];
  }

  Matrix2x2.rotate(double radians) {
    this.values = [[cos(radians), sin(radians)], [-sin(radians), cos(radians)]];
  }
}