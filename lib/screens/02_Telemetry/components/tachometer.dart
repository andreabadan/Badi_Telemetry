import 'package:badi_telemetry/models/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:provider/provider.dart';

import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:badi_telemetry/constants.dart';

class Tachometer extends StatelessWidget {
  const Tachometer({
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var bluetoothState = context.watch<BluetoothController>().bluetoothState;
    return Container(
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: (bluetoothState == DeviceConnectionState.connected) ? _TachometerWidget() : loading(),
      ),
    );
  }
}

class _TachometerWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    var tachometerData = context.watch<BluetoothController>().tachometerData;
    
    return SafeArea( 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
        children: <Widget>[
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                showAxisLine: false,
                minimum: 0,
                maximum: 16,
                startAngle: 130,
                endAngle: 410,
                ticksPosition: ElementsPosition.outside,
                labelsPosition: ElementsPosition.outside,
                radiusFactor: 0.9,
                canRotateLabels: true,
                majorTickStyle: const MajorTickStyle(
                  length: 0.1,
                  thickness: 1.5,
                  lengthUnit: GaugeSizeUnit.factor,
                ),
                minorTickStyle: const MinorTickStyle(
                  length: 0.04,
                  thickness: 1.5,
                  lengthUnit: GaugeSizeUnit.factor,
                ),
                minorTicksPerInterval: 1,
                interval: 1,
                labelOffset: 10,
                axisLabelStyle: const GaugeTextStyle(fontSize: 12),
                useRangeColorForAxis: true,
                pointers: <GaugePointer>[
                  NeedlePointer(
                    needleStartWidth: 1,
                    enableAnimation: true,
                    value: tachometerData.rpmDisplay/1000,
                    tailStyle: const TailStyle(
                        length: 0.2, width: 5, lengthUnit: GaugeSizeUnit.factor),
                    needleEndWidth: 5,
                    needleLength: 0.7,
                    lengthUnit: GaugeSizeUnit.factor,
                    knobStyle: const KnobStyle(
                      knobRadius: 0.08,
                      sizeUnit: GaugeSizeUnit.factor,
                    )
                  )
                ],
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 4,
                      endValue: 16,
                      startWidth: 0.01,
                      /// Sweep gradient not supported in web
                      gradient: const SweepGradient(
                        colors: <Color>[Colors.yellow, 
                                        Color(0xFFB71C1C)],
                        stops: <double>[0.25, 1]),
                      color: Colors.blue,
                      rangeOffset: 0.05,
                      endWidth: 0.08,
                      sizeUnit: GaugeSizeUnit.factor
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      tachometerData.rpmDisplay>1000
                        ?(tachometerData.rpmDisplay/1000).toStringAsFixed(3)+' rpm'
                        :tachometerData.rpmDisplay.toString()+' rpm',
                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
                      ),
                    angle: 90, positionFactor: 0.8
                  ),
                ]
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.none,
                    child:Text(
                        tachometerData.lapDisplay.getEllapsedTime(),
                        //TODO: fix text
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                  ),
                  CustomScrollView(
                    shrinkWrap: true,
                    slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index){
                              return tachometerData.lapDisplay.getLaps()[index];
                            },
                            childCount: tachometerData.lapDisplay.getLaps().length < 6
                              ? tachometerData.lapDisplay.getLaps().length
                              : 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                showAxisLine: false,
                minimum: 0,
                maximum: 160,
                startAngle: 130,
                endAngle: 410,
                ticksPosition: ElementsPosition.outside,
                labelsPosition: ElementsPosition.outside,
                radiusFactor: 0.9,
                canRotateLabels: true,
                majorTickStyle: const MajorTickStyle(
                  length: 0.1,
                  thickness: 1.5,
                  lengthUnit: GaugeSizeUnit.factor,
                ),
                minorTickStyle: const MinorTickStyle(
                  length: 0.04,
                  thickness: 1.5,
                  lengthUnit: GaugeSizeUnit.factor,
                ),
                minorTicksPerInterval: 5,
                interval: 10,
                labelOffset: 10,
                axisLabelStyle: const GaugeTextStyle(fontSize: 12),
                useRangeColorForAxis: true,
                pointers: <GaugePointer>[
                  NeedlePointer(
                    needleStartWidth: 1,
                    enableAnimation: true,
                    value: tachometerData.temperatureDisplay,
                    tailStyle: const TailStyle(
                      length: 0.2, width: 5, lengthUnit: GaugeSizeUnit.factor),
                    needleEndWidth: 5,
                    needleLength: 0.7,
                    lengthUnit: GaugeSizeUnit.factor,
                    knobStyle: const KnobStyle(
                      knobRadius: 0.08,
                      sizeUnit: GaugeSizeUnit.factor,
                    )
                  )
                ],
                ranges: <GaugeRange>[
                  GaugeRange(
                      startValue: 50,
                      endValue: 160,
                      startWidth: 0.01,
                      /// Sweep gradient not supported in web
                      gradient: const SweepGradient(
                        colors: <Color>[Colors.yellow, 
                                        Color(0xFFB71C1C)],
                        stops: <double>[0.25, 1]),
                      color: Colors.blue,
                      rangeOffset: 0.05,
                      endWidth: 0.08,
                      sizeUnit: GaugeSizeUnit.factor
                  )
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(tachometerData.temperatureDisplay!=999.9
                        ?tachometerData.temperatureDisplay.toString()+' °C'
                        :"Probe Broken",
                      style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
                      ),
                    angle: 90, positionFactor: 0.8
                  )
                ]
              ),
            ],
          ),
        ],
      ),
    );
  }
}
