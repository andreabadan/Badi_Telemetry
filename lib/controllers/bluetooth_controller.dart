import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:badi_telemetry/constants.dart';


class BluetoothController extends ChangeNotifier {

  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> foundBleUARTDevices = [];
  DiscoveredDevice? connectedDevice;
  late StreamSubscription<DiscoveredDevice> scanStream;
  late Stream<ConnectionStateUpdate> currentConnectionStream;
  late StreamSubscription<ConnectionStateUpdate> connection;
  late QualifiedCharacteristic txCharacteristic;
  late QualifiedCharacteristic rxCharacteristic;
  late Stream<List<int>> receivedDataStream;
  BluetoothData tachometerData = BluetoothData();
  late TextEditingController dataToSendText;
  bool scanning = false;
  DeviceConnectionState bluetoothState = DeviceConnectionState.disconnected;
  String logTexts = "";
  bool writing = false;

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
    if (tachometerData.newData(data)) {
      _refreshScreen();
    }
  }

  void disconnect() async {
    _printLog("Disconnecting...");
    bluetoothState  = DeviceConnectionState.disconnecting;
    _refreshScreen();
    
    await connection.cancel();
    _printLog("Disconnected!");
    bluetoothState  = DeviceConnectionState.disconnected;
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
    connectedDevice = foundBleUARTDevices[index];
    currentConnectionStream = flutterReactiveBle.connectToDevice(
      id:foundBleUARTDevices[index].id,
      connectionTimeout: const Duration(seconds: 5)
      /*prescanDuration: const Duration(seconds: 5),
      withServices: [serviceUUID, rxUUID, txUUID],*/
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
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                textColor: Colors.white,
                fontSize: 16.0
            );
  }
}

class BluetoothData {
  late String rpm;
  late String temperature;
  late String lap;
  late String bufferBT;
  late int rpmDisplay;
  late double temperatureDisplay;
  late LapTime lapDisplay;
  late int dataType;

  BluetoothData(){
    rpm = "";
    temperature = "";
    lap = "";
    bufferBT = "";
    rpmDisplay = 0;
    temperatureDisplay = 0.0;
    lapDisplay = LapTime();
    dataType = 0;
  }

  bool newData(List<int> data) { 
    bool updateData = false;
    for (var byte in data) {
      switch(byte){
        case tempCharacter:
          if(bufferBT != "") {
            debugPrint(bufferBT);
            if(bufferBT.substring(0,1) == tempProbeBrokenCharacter) {
              temperature = "0.0";
              updateData = true;
            } else {
              //in case of error on communication line discard message
              double? t = double.tryParse(bufferBT);
              if(t != null){
                temperatureDisplay = t/10.0;
                updateData = true;
              }
            }
          }
          bufferBT = "";
        break;

        case rpmCharacter:
          if(bufferBT != "") {
            debugPrint(bufferBT);
            //in case of error on communication line discard message
            int? t = int.tryParse(bufferBT);
            if(t != null) {
              rpmDisplay = t;
              updateData = true;
            }
          }
          bufferBT = "";
        break;

        case lapCharacter:
          if(bufferBT != "") {
            debugPrint(bufferBT);
            int? t;
            if(bufferBT.substring(0,1) == lapFinishedCharacter){
              lapDisplay.setLapFinished(true);
              //in case of error on communication line discard message
              t = int.tryParse(bufferBT.substring(1));
              if(t != null) {
                lapDisplay.setTime(int.parse(bufferBT.substring(1)));
                updateData = true;
              }
            } else {
              //in case of error on communication line discard message
              t = int.tryParse(bufferBT);
              if(t != null) {
                lapDisplay.setTime(t);
                updateData = true;
              }
            }
          }
          bufferBT = "";
        break;

        default:
          //create data
          bufferBT += String.fromCharCodes([byte]);
        }
      } 
    return updateData;    
  }
}

class LapTime {
  late int _milliseconds;
  late bool _lapFinished;
  late List <Text> _laps;
  
  LapTime(){
     _milliseconds = 0;
     _lapFinished  = false;
     _laps = <Text>[];
  }

  void setTime(int milliseconds){
    _milliseconds = milliseconds;
    if(_lapFinished){
      _lapFinished = false;
      _laps.insert(
        0,
        Text(
          (_laps.length +1).toString() + ": " + _ellapsedTime(_milliseconds), 
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
          )
        )
      );
    }
  }

  void setLapFinished(bool finish){
    _lapFinished = finish;
  }

  String getEllapsedTime(){
    return(_ellapsedTime(_milliseconds));
  }

  List <Text> getLaps(){
    return _laps;
  }

  String _ellapsedTime(millis){
    var minutes      = millis~/(60000);
    var milliseconds = millis - minutes*60000;
    var seconds      = milliseconds~/(1000);
    milliseconds    -= seconds*1000;
    
    var ellapsedTime = milliseconds.toString();
    if(ellapsedTime.length == 1) {
      ellapsedTime = "00" + ellapsedTime;
    } else if(ellapsedTime.length == 2) {
      ellapsedTime = "0" + ellapsedTime;
    }
    
    ellapsedTime = seconds.toString() + ":" + ellapsedTime;
    if(ellapsedTime.length == 5) {
      ellapsedTime = "0" + ellapsedTime;
    }
    
    return(minutes.toString() + ":" + ellapsedTime);
  }
}