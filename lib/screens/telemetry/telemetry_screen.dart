import 'package:badi_telemetry/screens/telemetry/components/tachometer.dart';
import 'package:badi_telemetry/screens/telemetry/components/header.dart';
import 'package:flutter/material.dart';


class Telemetry extends StatelessWidget {
  const Telemetry({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Tachometer(),
        Positioned(
          top: 5,
          left: 5,
          child: Header(),
        ),
      ]
    );
  }
}