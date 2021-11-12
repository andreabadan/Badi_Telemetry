import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

import 'package:badi_telemetry/constants.dart';

class BtFindList extends StatelessWidget {
  const BtFindList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child:_ListFoundDevices(),
      ),
    );
  }
}

class _ListFoundDevices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bluetooth = context.watch<BluetoothController>();
    if(bluetooth.scanning) {
      if(bluetooth.foundBleUARTDevices.isNotEmpty) {
        if(bluetooth.bluetoothState == DeviceConnectionState.disconnected) {
          return DataTable2 (
            columnSpacing: defaultPadding,
            minWidth: 600,
            //onSelectChanged:(int index) => Provider.of<BluetoothController>(context, listen: false).onConnectDevice(index);,
            columns:[
              DataColumn(
                label: Text("DEVICE NAME",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              DataColumn(
                label: Text("MAC",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              DataColumn(
                label: Text("STATUS",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
            ],
            rows:List.generate(
              bluetooth.foundBleUARTDevices.length,
              (index) //=> devicesDataRow(bluetooth.foundBleUARTDevices[index], index),
              { 
                return DataRow2(
                  onTap: ()=> Provider.of<BluetoothController>(context, listen: false).onConnectDevice(index),
                  cells: [
                    DataCell(Text(bluetooth.foundBleUARTDevices[index].name)),
                    DataCell(Text(bluetooth.foundBleUARTDevices[index].id)),
                    const DataCell(Text("Ready to connect!")),
                  ],
                );
              }
            ),
          );
        } else {
          return Text(
            "Scanning . . .",
            style: Theme.of(context).textTheme.subtitle1,
          );
        }
      } else {
        return const SpinKitFadingCircle(
          color: primaryColor,
          size: 70.0,
        );
      }
    } else {
      return Text(
        "Start scan to continue",
        style: Theme.of(context).textTheme.subtitle1,
      );
    }
  }
}