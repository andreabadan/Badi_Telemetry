import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import 'package:badi_telemetry/constants.dart';

class BtFindList extends StatelessWidget {
  const BtFindList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Founded Devices",
            style: Theme.of(context).textTheme.subtitle1,
          ),
          SizedBox(
            width: double.infinity,
            child:_ListFoundDevices(),
          ),
        ],
      ),
    );
  }
}

class _ListFoundDevices extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bluetooth = context.watch<BluetoothController>();
    if(bluetooth.scanning) {
      return DataTable2 (
        columnSpacing: defaultPadding,
        minWidth: 600,
        columns: const [
          DataColumn(
            label: Text("Device Name"),
          ),
          DataColumn(
            label: Text("MAC"),
          ),
          DataColumn(
            label: Text("Status"),
          ),
        ],
        rows:List.generate(
          bluetooth.foundBleUARTDevices.length,
          (index) => devicesDataRow(bluetooth.foundBleUARTDevices[index]),
        ),
      );
    } else {
      return DataTable2 (
        columnSpacing: defaultPadding,
        minWidth: 600,
        columns: const [
          DataColumn(
            label: Text("Start scan to continue"),
          ),
        ],
        rows:const []
      );
    }
  }
}

DataRow devicesDataRow(DiscoveredDevice device) {
  return DataRow(
    cells: [
      DataCell(Text(device.name)),
      DataCell(Text(device.id)),
      DataCell(Text(device.id)),
    ],
  );
}