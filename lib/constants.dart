import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const primaryColor   = Color(0xFF2697FF);
const secondaryColor = Color(0xFF2A2D3E);
const bgColor        = Color(0xFF212332);

const itemSelectableColor    = Colors.white;
const itemNotSelectableColor = Colors.white12;

const defaultPadding = 16.0;

final Uuid serviceUUID = Uuid.parse("0000FFE0-0000-1000-8000-00805F9B34FB");
final Uuid rxUUID      = Uuid.parse("0000FFE2-0000-1000-8000-00805F9B34FB");
final Uuid txUUID      = Uuid.parse("0000FFE1-0000-1000-8000-00805F9B34FB");
//Time to wait during Jump to bootloader
const bootloaderWaitTime = 5000;
const ackReceived = 500;

//Escape Characters
const tempCharacter    = 84;//T
const rpmCharacter     = 82;//R
const lapCharacter     = 76;//L
const versionCharacter = 86;//V
//Description Strings
const tempProbeBrokenCharacter = "B";//66 B
const highTempCharacter        = "H";//72 H
const lapFinishedCharacter     = "F";//70 F
//Send Strings
const checkFirmwareVersion = "FWV";
const jumpToBootloader     = "BOOT";
//Bootloader comand strings
const eraseFlashMemory  = "#\$ERASE_MEMORY";
const flashingStart     = "#\$FLASH_START#";
const flashingFinish    = "#\$FLASH_FINISH";
const flashingAbort     = "#\$FLASH_ABORT#";
const applicationStart  = "#\$APPL_START\$#";
const commandLenght     = 8;
//Bootloader response
const bootloaderRunning = 98;//b
const flashingError     = 101;//e
const flashingOk        = 107;//k

enum IndexMenuState {
  //Main page search
  search,

  //Main page telemetry
  telemetry,

  //Update firmware page
  updateFirmware,

  //Graph page
  graph,

  //Settings page
  settings,

  //Info page
  info
}

enum ProbeStatus {
  //Probe OK -> no problem
	probeOk,

  //Probe not connected or short-circuited
	probeBroken,

  //High temperature alarm
	highTemperature
}

class Routes {
  static const String search         = "/search";
  static const String telemetry      = "/telemetry";
  static const String updateFirmware = "/updateFirmware";
  static const String graph          = "/graph";
  static const String settings       = "/settings";
  static const String info           = "/info";
}

