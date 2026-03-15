import 'dart:svg';

import 'sunflower.dart';
import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class Seed {
  int index;
  int colorIndex;
  String color = "white";
  CanvasRenderingContext2D canvas;
  Sunflower? sunflower;
  num posX = 0;
  num posY = 0;
  num vecX = 0;
  num vecY = 0;
  static Vector2 positionMax = Vector2(0.0, 0.0);

  static num SEED_RADIUS = 2;
  static num TAU = pi * 2;

  static List<String> colors = <String>["red", "blue", "yellow", "hotpink", "darkturquoise", "sienna", "dimgray"];
  static List<String> colorsFr = <String>["rouge", "bleu", "jaune", "rose", "turquoise", "brun", "gris"];

  Seed (this.index, this.colorIndex, this.canvas) {
    color = colors[colorIndex];
  }

  void draw() {
    posX = posX % positionMax.x;
    posY = posY % positionMax.y;
    canvas..beginPath()
      ..fillStyle = color
      ..arc(posX, posY, SEED_RADIUS, 0, TAU, false)
      ..closePath()
      ..fill();
  }
  
  String shortNumber(num d) {
    String retStr = "";
    if (d.abs() > 10000) { retStr = (d.round()).toString(); }
    else if (d.abs() > 1000) { retStr = ((d*10).round()/10).toString(); }
    else if (d.abs() > 100) { retStr = ((d*100).round()/100).toString(); }
    else if (d.abs() > 10) { retStr = ((d*1000).round()/1000).toString(); }
    else if (d.abs() > 1) { retStr = ((d*10000).round()/10000).toString(); }
    else if (d.abs() > 0) { retStr = ((d*100000).round()/100000).toString(); }
    else if (d == 0) { retStr = "0"; }
    return retStr;
  }

  String toSvg() {
    return '<circle cx="${shortNumber(posX)}" cy="${shortNumber(posY)}" r="${shortNumber(SEED_RADIUS)}" fill="$color" />';
  }
}