import 'dart:async';
import 'dart:ui';
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
    DatabaseService dbs = DatabaseService();
    LocationModel? locat = LocationModel();
    List<PositionModel> latList = [];

    locat = await dbs.readLocationData();
    // await Firebase.initializeApp(
    //   options: DefaultFirebaseOptions.android,
    // );
    if (locat == null || locat.location == null) {
      latList = [];
      locat = LocationModel(location: []);
    } else {
      latList = locat.location!;
    }
    LocationService sf = LocationService();
    // FirebaseDB db = FirebaseDB();
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
    locat.location = latList;
    dbs.saveDataLocally(locat);
    print("Task Return");
    // await db.addLocationData(latList);
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
      home: const MyHomePage(title: 'Location Data'),
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
  bool isLoading = false;
  LocationService locationService = LocationService();
  FirebaseDB db = FirebaseDB();
  List<PositionModel> latList = [];
  LocationModel? locationData = LocationModel();
  final DatabaseService database = DatabaseService();

  void loadingOn() {
    setState(() {
      isLoading = true;
    });
  }

  void loadingOff() {
    setState(() {
      isLoading = false;
    });
  }

  Future<void> fetchLocationData() async {
    loadingOn();
    locationData = await database.readLocationData();
    loadingOff();
  }

  Future<void> getLocation() async {
    loadingOn();
    await locationService.getLocation();
    await locationService.determinePosition();
    locationData = await database.readLocationData();
    loadingOff();
  }

  @override
  void initState() {
    getLocation();

    // database.createDatabase();
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SizedBox(
        width: size.width,
        height: size.height * 0.8,
        child: SingleChildScrollView(
          child: isLoading == true
              ? const Center(
                  heightFactor: 40, child: CircularProgressIndicator())
              : locationData == null || locationData?.location == null
                  ? const Center(
                      heightFactor: 40, child: Text("No Location Data"))
                  : SizedBox(
                      width: size.width,
                      height: size.height * 0.8,
                      child: ListView.builder(
                          itemCount: locationData?.location?.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                      "lat: ${locationData?.location![index].lat}"),
                                  Text(
                                      "long: ${locationData?.location![index].long}"),
                                ],
                              ),
                            );
                          }),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await db.addLocationData(latList);
          database.removeValues();
          // database.readLocationData();
          await fetchLocationData();
        },
        tooltip: 'Increment',
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}
