import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:external_path/external_path.dart';

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
  bool scanning = false;
  DeviceConnectionState bluetoothState = DeviceConnectionState.disconnected;
  String logTexts = "";
  bool writing = false;

  void _refreshScreen() {
    notifyListeners();
  }

  Future<void> sendCommand(String valueToSend) {
    return flutterReactiveBle.writeCharacteristicWithResponse(rxCharacteristic, value: valueToSend.codeUnits);
  }

  Future<Uint8List> _binFile(String binName) async {
    final String path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    //Read as bytes
    if (await Permission.storage.request().isGranted) {
      return File('$path/$binName').readAsBytes();
    } 
    else {
      return Future.error('Permission denided');
    }
  }
  Future<void> sendBin(String binName) async {
    final Uint8List binFile = await _binFile(binName).catchError((onError){
      _printLog(onError);
      return onError;
    });

    for(var i=0; i<=binFile.length; i=i+commandLenght){
      tachometerData.bootloaderErrorReceived = false;
      tachometerData.bootloaderOkReceived = false;
      await flutterReactiveBle.writeCharacteristicWithResponse(rxCharacteristic, value: binFile.sublist(i, i+commandLenght>binFile.length? binFile.length : i+commandLenght))
        .catchError((onError){
          _printLog(onError);
          return onError;
        });
      if(((i*100)/binFile.length).round() != tachometerData.updatePercentage){ 
        tachometerData.updatePercentage = ((i*100)/binFile.length).round();
        _refreshScreen();
      }
      for(int i=0; i<10; i++){
        await Future<void>.delayed(const Duration(milliseconds: ackReceived~/10));
        if(tachometerData.bootloaderOkReceived || tachometerData.bootloaderErrorReceived){
          break;
        }
      }
      if(!tachometerData.bootloaderOkReceived){
        return Future.error('Error during comunication');
      }
    }
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

  void writeFW() async {
    sendCommand(jumpToBootloader);
    tachometerData.updatePercentage = 0;
    _refreshScreen();
    _printLog("Reboot in bootloader mode");
    //Wait before jump to bootloader mode
    for(int i=0; i<100; i++){
      await Future<void>.delayed(const Duration(milliseconds: bootloaderWaitTime~/100));
      if(tachometerData.bootloaderMode){
        break;
      }
    }
    //Check if board is in bootloader mode
    if(tachometerData.bootloaderMode) {
      _printLog("Update started!");
      await sendCommand(flashingStart)          .catchError((onError) => _printLog("0x002: Error during Ereasing!"));
      await sendBin("BadiApp_STM32F103CBT6.bin").catchError((onError) => _printLog("0x003: Error during writing!"));
      await sendCommand(flashingFinish)         .catchError((onError) => _printLog("0x004: Error during Reboot!"));
    } else {
      _printLog("0x001: Error during reconnection!");
    }
    tachometerData.updatePercentage = 100;
    tachometerData.bootloaderMode = false;
    tachometerData.bootloaderOkReceived = false;
    tachometerData.bootloaderErrorReceived = false;
    _refreshScreen();
  }
}

class BluetoothData {
  late String bufferBT;
  late int rpmDisplay;
  late double temperatureDisplay;
  late ProbeStatus temperatureProbeStatus;
  late LapTime lapDisplay;
  late String version;
  late int updatePercentage;

  late bool bootloaderMode;
  late bool bootloaderOkReceived;
  late bool bootloaderErrorReceived;

  late int dataType;

  BluetoothData(){
    bufferBT = "";
    rpmDisplay = 0;
    temperatureDisplay = 0.0;
    temperatureProbeStatus = ProbeStatus.probeOk;
    lapDisplay = LapTime();
    version = "";
    updatePercentage = 100;

    bootloaderMode = false;
    bootloaderOkReceived = false;
    bootloaderErrorReceived = false;

    dataType = 0;
  }

  bool newData(List<int> data) { 
    bool updateData = false;
    for (var byte in data) {
      switch(byte){
        /*********************/
        /*APPLICATION MESSAGE*/
        /*********************/
        case tempCharacter:
          if(bufferBT != "") {
            debugPrint(bufferBT);
            switch(bufferBT.substring(0,1)){
              case tempProbeBrokenCharacter:
                temperatureDisplay = 0.0;
                temperatureProbeStatus = ProbeStatus.probeBroken;
                updateData = true;
                break;
              case highTempCharacter:
                temperatureProbeStatus = ProbeStatus.highTemperature;
                break;
              default:
                temperatureProbeStatus = ProbeStatus.probeOk;
                break;
            }
            if(temperatureProbeStatus != ProbeStatus.probeBroken) {
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

        case versionCharacter:
          debugPrint(bufferBT);
          version = bufferBT;
          updateData = true;
          bufferBT = "";
          break;
        /********************/
        /*BOOTLOADER MESSAGE*/
        /********************/
        case bootloaderRunning:
          bootloaderMode = true;
          bufferBT = "";
          break;

        case flashingError:
          bootloaderErrorReceived = true;
          bufferBT = "";
          break;
        
        case flashingOk:
          bootloaderOkReceived = true;
          bufferBT = "";
          break;

        default:
          //create data
          bufferBT += String.fromCharCodes([byte]);
          debugPrint(bufferBT);
          break;
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