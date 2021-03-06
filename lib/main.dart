import 'package:flutter/material.dart';
import 'login.dart';

/*void main(List<String> args) {
  runApp(Cts());
}*/

void main() {
  runApp(Cts());
}

class Cts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}
