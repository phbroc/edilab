import 'package:edilab/edilab_app.dart';

late AcediApp app;

void main() {
  app = AcediApp();
  app.init("#screen", 1, 1);
  app.draw();
}
