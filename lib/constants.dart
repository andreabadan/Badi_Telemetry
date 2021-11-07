import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const primaryColor = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor = Color(0xFF212332);

const defaultPadding = 16.0;

final Uuid serviceUUID = Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
final Uuid rxUUID      = Uuid.parse("0000FFE2-0000-1000-8000-00805F9B34FB");
final Uuid txUUID      = Uuid.parse("0000FFE1-0000-1000-8000-00805F9B34FB");