import 'dart:async';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example01/models/position_model.dart';
import 'package:example01/service/database.dart';
import 'package:example01/service/firebase_service.dart';
import 'package:example01/service/location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';
import 'models/location_model.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    List<PositionModel> latList = [];
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.android,
    // );
    LocationService sf = LocationService();
    FirebaseDB db = FirebaseDB();
    print("Task Run");
    List<int> list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
    for (var i in list) {
      await Future.delayed(const Duration(minutes: 1));
      // Position ss = await Geolocator.getCurrentPosition();
      Position position = await sf.determinePosition();
      PositionModel model = PositionModel();
      model.lat = position.latitude;
      model.long = position.longitude;
      latList.add(model);

      print("TASK $i ${position.latitude}");
      print("LENGTH $i ${latList.length}");
    }
    await db.addLocationData(latList);
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  LocationService locationService = LocationService();

  Future<void> getLocation() async {
    await locationService.getLocation();
    await locationService.determinePosition();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final DatabaseService database = DatabaseService();

  @override
  void initState() {
    getLocation();

    database.createDatabase();
    // Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    // Workmanager().registerOneOffTask("task-identifier", "simpleTask");
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    Workmanager().registerPeriodicTask("task-identifier", "simpleTask");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
