import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:badi_telemetry/controllers/bluetooth_controller.dart';

import 'package:badi_telemetry/constants.dart';


class UpdateFirmwareProcess extends StatelessWidget {
  const UpdateFirmwareProcess({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int updatePercentage = context.watch<BluetoothController>().tachometerData.updatePercentage;
    return InkWell(
      onTap: () {
        if(updatePercentage == 100){
          Provider.of<BluetoothController>(context, listen: false).writeFW();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 0.75),
        margin: const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
        decoration: BoxDecoration(
          color: updatePercentage == 100? primaryColor : itemNotSelectableColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(
          updatePercentage == 100 ? "Write new firmware" : "Updating: $updatePercentage %",
          style: const TextStyle(
              color: itemSelectableColor
            ),
          ),
      ),
    );
  }
}