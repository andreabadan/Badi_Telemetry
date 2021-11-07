import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//import 'package:location_permissions/location_permissions.dart';

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
  bool connected = false;
  String logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;

  void initState() {
    dataToSendText = TextEditingController();
  }

  void refreshScreen() {
    notifyListeners();
    //setState(() {});
  }

  void _sendData() async {
      await flutterReactiveBle.writeCharacteristicWithResponse(rxCharacteristic, value: dataToSendText.text.codeUnits);
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    _receivedData.add( "$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");
    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    refreshScreen();
  }

  void _disconnect() async {
    await connection.cancel();
    connected = false;
    refreshScreen();
  }

  void _stopScan() async {
    await scanStream.cancel();
    scanning = false;
    refreshScreen();
  }

  /*Future<void> showNoPermissionDialog() async => showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) => AlertDialog(
          title: const Text('No location permission '),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('No location permission granted.'),
                const Text('Location permission is required for BLE to function.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
    );
    TODO: Into right page
    */

  void startScan() async {
    bool goForIt=true;
    /*bool goForIt=false;
    PermissionStatus permission ;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) {
        goForIt = true;
      }
    } else if (Platform.isIOS) {
      goForIt=true;
      //goForIt = permission == PermissionStatus.granted;
      //TODO:Test with IOS
    }*/
    if (goForIt) {
      foundBleUARTDevices = [];
      scanning = true;
      refreshScreen();
      scanStream =
          flutterReactiveBle.scanForDevices(withServices: [serviceUUID]).listen((
              device) {
            if (foundBleUARTDevices.every((element) =>
            element.id != device.id)) {
              foundBleUARTDevices.add(device);
              refreshScreen();
            }
          }, onError: (Object error) {
            logTexts = "${logTexts}ERROR while scanning:$error \n";
            refreshScreen();
          }
          );
    }
    /*
    TODO: Into right page
    else {
      await showNoPermissionDialog();
    }*/
  }

  void onConnectDevice(index) {
    currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id:foundBleUARTDevices[index].id,
      prescanDuration: Duration(seconds: 1),
      withServices: [serviceUUID, rxUUID, txUUID],
    );
    logTexts = "";
    refreshScreen();
    connection = currentConnectionStream.listen((event) {
      var id = event.deviceId.toString();
      switch(event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            logTexts = "${logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            connected = true;
            logTexts = "${logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            txCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: txUUID, deviceId: event.deviceId);
            receivedDataStream = flutterReactiveBle.subscribeToCharacteristic(txCharacteristic);
            receivedDataStream.listen((data) {
               onNewReceivedData(data);
            }, onError: (dynamic error) {
              logTexts = "${logTexts}Error:$error$id\n";
            });
            rxCharacteristic = QualifiedCharacteristic(serviceId: serviceUUID, characteristicId: rxUUID, deviceId: event.deviceId);
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            connected = false;
            logTexts = "${logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            logTexts = "${logTexts}Disconnected from $id\n";
            break;
          }
      }
      refreshScreen();
    });
  }

  
}