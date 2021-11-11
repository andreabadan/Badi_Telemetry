import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:badi_telemetry/constants.dart';

import 'dart:io' show Platform;

class BluetoothController extends ChangeNotifier {

  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> scanStream;
  late Stream<ConnectionStateUpdate> currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> connection;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic rxCharacteristic;
  late Stream<List<int>> receivedDataStream;
  late TextEditingController dataToSendText;
  bool scanning = false;
  DeviceConnectionState bluetoothState = DeviceConnectionState.disconnected;
  String logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;

  void initState() {
    dataToSendText = TextEditingController();
  }

  void _refreshScreen() {
    notifyListeners();
  }

  void sendData() async {
      await flutterReactiveBle.writeCharacteristicWithResponse(rxCharacteristic, value: dataToSendText.text.codeUnits);
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    _receivedData.add( "$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");
    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    _refreshScreen();
  }

  void disconnect() async {
    await connection.cancel();
    _refreshScreen();
  }

  void stopScan() async {
    await scanStream.cancel();
    scanning = false;
    _refreshScreen();
  }

  void startScan() async {
    /*if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        goForIt = true;
      }
    } else if (Platform.isIOS) {
      goForIt=true;
      //goForIt = permission == PermissionStatus.granted;
    }*/
    if (await Permission.location.request().isGranted) {
      //TODO: Test with IOS device
      foundBleUARTDevices = [];
      scanning = true;
      _refreshScreen();
      scanStream = flutterReactiveBle.scanForDevices(withServices: [serviceUUID]).listen((device) {
        if (foundBleUARTDevices.every((element) =>
        element.id != device.id)) {
          foundBleUARTDevices.add(device);
          _refreshScreen();
        }
      }, 
      onError: (Object error) {
        scanning = false;
        _refreshScreen();
        logTexts = "${logTexts}ERROR while scanning:$error \n";
        _printLog(error.toString());
      });
    }
    /*
    TODO: Into right page
    else {
      await showNoPermissionDialog();
    }*/
  }

  void onConnectDevice(index) {
    stopScan();
    currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id:foundBleUARTDevices[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [serviceUUID, rxUUID, txUUID],
    );
    logTexts = "";
    _refreshScreen();
    connection = currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      bluetoothState = event.connectionState;
      switch(bluetoothState) {
        case DeviceConnectionState.connecting:
        {
          logTexts = "${logTexts}Connecting to $id\n";
          _printLog("Connecting...");
          break;
        }
        case DeviceConnectionState.connected:
        {
          logTexts = "${logTexts}Connected to $id\n";
          _printLog("Connected!");
          _numberOfMessagesReceived = 0;
          _receivedData = [];
          txCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: txUUID, deviceId: event.deviceId);
          receivedDataStream = flutterReactiveBle.subscribeToCharacteristic(txCharacteristic);
          receivedDataStream.listen((data) {
              onNewReceivedData(data);
          }, onError: (dynamic error) {
            logTexts = "${logTexts}Error:$error$id\n";
            _printLog(error.toString()+id.toString());
          });
          rxCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: rxUUID, deviceId: event.deviceId);
          break;
        }
        case DeviceConnectionState.disconnecting:
        {
          logTexts = "${logTexts}Disconnecting from $id\n";
          _printLog("Disconnecting...");
          break;
        }
        case DeviceConnectionState.disconnected:
        {
          logTexts = "${logTexts}Disconnected from $id\n";
          _printLog("Disconnected!");
          break;
        }
      }
      _refreshScreen();
    });
  }

  void _printLog(String log){
    Fluttertoast.showToast(
                msg: log,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                textColor: Colors.white,
                fontSize: 16.0
            );
  }
}