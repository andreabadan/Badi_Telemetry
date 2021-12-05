import 'package:badi_telemetry/screens/01_Search/search_screen.dart';
import 'package:badi_telemetry/screens/02_Telemetry/telemetry_screen.dart';
import 'package:badi_telemetry/screens/03_UpdateFirmware/update_firmware.dart';
import 'package:badi_telemetry/screens/04_Graph/graph.dart';
import 'package:badi_telemetry/screens/05_Settings/settings.dart';
import 'package:badi_telemetry/screens/06_Info/info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:badi_telemetry/constants.dart';

class MenuController extends ChangeNotifier {
  MenuController();

  DeviceConnectionState _deviceConnectionState = DeviceConnectionState.disconnected;
  IndexMenuState indexMenu = IndexMenuState.search;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  DeviceConnectionState get deviceConnectionState => _deviceConnectionState;

  void update(DeviceConnectionState state){
    if (state == DeviceConnectionState.disconnected){
      if(indexMenu == IndexMenuState.telemetry) {
        setIndexMenuState(IndexMenuState.search);
      }
    }
    if (state == DeviceConnectionState.connected){
      if(indexMenu == IndexMenuState.search) {
        setIndexMenuState(IndexMenuState.telemetry);
      }  
    }
    
    _deviceConnectionState = state;
  }

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  IndexMenuState get getIndexMenuState => indexMenu;
  
  void setIndexMenuState(IndexMenuState indexMenu){
    this.indexMenu = indexMenu;
    notifyListeners();
  }

  Widget get getNavigation {
    switch(indexMenu){
      case IndexMenuState.search:
        return const Search();
      case IndexMenuState.telemetry:
        return const Telemetry();
      case IndexMenuState.updateFirmware:
        return const UpdateFirmware();
      case IndexMenuState.graph:
        return const Graph();
      case IndexMenuState.info:
        return const Info();
      case IndexMenuState.settings:
        return const Settings();
    }
  }
}
