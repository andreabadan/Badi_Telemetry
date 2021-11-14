import 'package:flutter/material.dart';

import 'package:badi_telemetry/constants.dart';

class MenuController extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  IndexMenuState indexMenu = IndexMenuState.main;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  IndexMenuState get getIndexMenuState => indexMenu;
  
  void setIndexMenuState(IndexMenuState indexMenu){
     this.indexMenu = indexMenu;
     //TODO: Use [Navigator.pop] to close the drawer once it is open
     notifyListeners();
  }

  //TODO: Link to Bluetooth provider and change "indexMenu" in case of incompatibilty with status of connection
}
