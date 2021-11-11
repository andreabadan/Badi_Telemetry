import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Telemetry extends StatelessWidget {
  const Telemetry({
    Key? key,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    const spinkit = SpinKitFadingCircle(
      color: Colors.lightBlue,
      size: 70.0,
    );
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.menu),
        title: Text(widget().device.name),
        //actions: If someone want add actions
      ),
      body: StreamBuilder<BluetoothDeviceState>(
        stream: widget().device.state,
        initialData: BluetoothDeviceState.connecting,
        builder: (c, snapshot) {
          switch (snapshot.data) {
            case BluetoothDeviceState.connected:
              return _tachometerWidget();                   
            default:
              //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connecting... Please wait!')));
              return spinkit;
          }
        },
      )
    );
  }
  
  SafeArea _tachometerWidget()=> //Tachometer
  SafeArea( 
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
                  value: rpmDisplay/1000,
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
                    rpmDisplay>1000
                      ?(rpmDisplay/1000).toStringAsFixed(3)+' rpm'
                      :rpmDisplay.toString()+' rpm',
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
                      lapDisplay.getEllapsedTime(),
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
                            return lapDisplay.getLaps()[index];
                          },
                          childCount: lapDisplay.getLaps().length < 6
                            ? lapDisplay.getLaps().length
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
                  value: temperatureDisplay,
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
                  widget: Text(temperatureDisplay!=999.9
                      ?temperatureDisplay.toString()+' °C'
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


  void _onDataReceived(List<int> data) { 
    for (var byte in data) {
      switch(byte){
        //search datatype
        case tempCharacter:
          if(bufferBT != "") {
            setState(() {
              if(bufferBT.substring(0,1) == tempProbeBrokenCharacter) {
                temperature = "0.0";
              } else {
                temperatureDisplay = double.parse(bufferBT)/10.0;
              }
            });
          }
          bufferBT = "";
        break;

        case rpmCharacter:
          if(bufferBT != "") {
            setState(() {
              rpmDisplay = int.parse(bufferBT);
            });
          }
          bufferBT = "";
        break;

        case lapCharacter:
          if(bufferBT != "") {
            setState(() {
              if(bufferBT.substring(0,1) == lapFinishedCharacter){
                lapDisplay.setLapFinished(true);
                lapDisplay.setTime(int.parse(bufferBT.substring(1)));
              }else {
                lapDisplay.setTime(int.parse(bufferBT));
              }
            });
          }
          bufferBT = "";
        break;

        default:
          //create data
          bufferBT += String.fromCharCodes([byte]);
        }
      }     
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

    return(minutes.toString() + ":" + seconds.toString() + ":" + milliseconds.toString());
  }
}    