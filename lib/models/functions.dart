import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:badi_telemetry/constants.dart';

Widget loading(){
  return const SpinKitFadingCircle(
    color: primaryColor,
    size: 70.0,
  );
}