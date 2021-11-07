import 'package:badi_telemetry/constants.dart';
import 'package:badi_telemetry/controllers/menu_controller.dart';
import 'package:badi_telemetry/controllers/bluetooth_controller.dart';
import 'package:badi_telemetry/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

<<<<<<< Updated upstream
import 'package:badi_telemetry/navigation_screen.dart';

=======
>>>>>>> Stashed changes
void main() {
  //Change rientation
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.lightBlue));
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const TelemetryApp());
}

class TelemetryApp extends StatelessWidget {
  const TelemetryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< Updated upstream
      color: Colors.lightBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return const NavigationScreen();
            }
            return BluetoothOffScreen(state: state);
          }),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {//Bluetooth Off 
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);

  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Bluetooth Adapter is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subtitle1!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
=======
      debugShowCheckedModeBanner: false,
      title: 'Badi Telemetry',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => MenuController()),
          ChangeNotifierProvider(create: (context) => BluetoothController()),
        ],
        child: const MainScreen(),
>>>>>>> Stashed changes
      ),
    );
  }
}