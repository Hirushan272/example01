import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
// import 'dart:html';

// import 'package:background_locator/background_locator.dart';
// import 'package:background_locator/location_dto.dart';
// import 'package:background_locator/settings/android_settings.dart';
// import 'package:background_locator/settings/ios_settings.dart';
// import 'package:background_locator/settings/locator_settings.dart';
import 'package:background_location_tracker/background_location_tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example01/models/position_model.dart';
import 'package:example01/service/database.dart';
import 'package:example01/service/firebase_service.dart';
import 'package:example01/service/location_repo.dart';
import 'package:example01/service/location_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:location/location.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'firebase_options.dart';
import 'models/location_model.dart';
import 'service/not-use/callback_handler.dart';
import 'service/not-use/location_service_repository.dart';

String? timeConvert(DateTime? time) {
  String? finalDate;
  try {
    String formattedDate = DateFormat.jm().format(time!);
    finalDate = formattedDate;
  } catch (e) {
    print("ERROR DATE $e");
  }
  return finalDate;
}

// void initTask() {
//   FlutterForegroundTask.init(
//       foregroundTaskOptions: ForegroundTaskOptions(),
//       androidNotificationOptions:
//           AndroidNotificationOptions(channelId: "", channelName: ""),
//       iosNotificationOptions: IOSNotificationOptions());

//   FlutterForegroundTask.startService(
//       notificationTitle: "notificationTitle", notificationText: "");
// }

@pragma('vm:entry-point')
void backgroundCallback() {
  BackgroundLocationTrackerManager.handleBackgroundUpdated(
    (data) async => Repo().update(data),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await BackgroundLocationTrackerManager.initialize(
    backgroundCallback,
    config: const BackgroundLocationTrackerConfig(
      loggingEnabled: true,
      androidConfig: AndroidConfig(
        notificationIcon: 'explore',
        trackingInterval: Duration(seconds: 10),
        // distanceFilterMeters: 0,
      ),
      iOSConfig: IOSConfig(
        activityType: ActivityType.FITNESS,
        // distanceFilterMeters: null,
        restartAfterKill: true,
      ),
    ),
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

  List<PositionModel> latList = [];
  LocationModel? locationData = LocationModel();
  final DatabaseService database = DatabaseService();

  var isTracking = false;
  Timer? _timer;

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

//////////////////////////////////////

  // static const String _isolateName = "LocatorIsolate";
  // ReceivePort port = ReceivePort();
  // String logStr = '';
  // bool? isRunning;
  // LocationDto? lastLocation;

  // Future<void> initPlatformState() async {
  //   await BackgroundLocator.initialize();
  // }

  // void callback(LocationDto locationDto) async {
  //   final SendPort? send = IsolateNameServer.lookupPortByName(_isolateName);
  //   send?.send(locationDto);
  // }

//Optional
  // void notificationCallback() {
  //   print('User clicked on the notification');
  // }

//////!
//Somewhere in your code
  // startLocationService();

  // void startLocationService(dynamic data) {
  //   BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
  //       initCallback: LocationCallbackHandler.initCallback,
  //       initDataCallback: data,
  //       disposeCallback: LocationCallbackHandler.disposeCallback,
  //       autoStop: false,
  //       iosSettings: const IOSSettings(
  //           accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
  //       androidSettings: const AndroidSettings(
  //           accuracy: LocationAccuracy.NAVIGATION,
  //           interval: 5,
  //           distanceFilter: 0,
  //           androidNotificationSettings: AndroidNotificationSettings(
  //               notificationChannelName: 'Location tracking',
  //               notificationTitle: 'Start Location Tracking',
  //               notificationMsg: 'Track location in background',
  //               notificationBigMsg:
  //                   'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
  //               notificationIcon: '',
  //               notificationIconColor: Colors.grey,
  //               notificationTapCallback:
  //                   LocationCallbackHandler.notificationCallback)));
  // }

//////!

  Future<void> _getTrackingStatus() async {
    isTracking = await BackgroundLocationTrackerManager.isTracking();
    setState(() {});
  }

  Future<void> _requestLocationPermission() async {
    final result = await Permission.locationAlways.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  Future<void> _requestNotificationPermission() async {
    final result = await Permission.notification.request();
    if (result == PermissionStatus.granted) {
      print('GRANTED'); // ignore: avoid_print
    } else {
      await Permission.notification.request();
      print('NOT GRANTED'); // ignore: avoid_print
    }
  }

  // LocationModel?

  Future<void> _getLocations() async {
    LocationModel? location = await LocationDao().readLocationData();

    print("RUN: _getLocation in main");
    setState(() {
      locationData = location;
    });
  }

  void _startLocationsUpdatesStream() {
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 30), (timer) => _getLocations());
  }

//////////////////////////////////////

  @override
  void initState() {
    super.initState();
    _getLocations();
    _getTrackingStatus();
    _startLocationsUpdatesStream();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
        // height: size.height * 0,
        child: Column(
          children: [
            ///////////////////////
            TextButton(
              onPressed: _requestLocationPermission,
              child: const Text('Request location permission'),
            ),

            TextButton(
              onPressed: _requestNotificationPermission,
              child: const Text('Request Notification permission'),
            ),
            TextButton(child: const Text('Send notification'), onPressed: () {}
                // sendNotification('Hello from another world'),
                ),
            TextButton(
              onPressed: isTracking
                  ? null
                  : () async {
                      await BackgroundLocationTrackerManager.startTracking();
                      setState(() => isTracking = true);
                    },
              child: const Text('Start Tracking'),
            ),
            TextButton(
              onPressed: isTracking
                  ? () async {
                      // await LocationDao().clear();
                      await _getLocations();
                      await BackgroundLocationTrackerManager.stopTracking();
                      setState(() => isTracking = false);
                    }
                  : null,
              child: const Text('Stop Tracking'),
            ),
            isLoading == true
                ? const Center(
                    heightFactor: 40, child: CircularProgressIndicator())
                : locationData == null || locationData?.location == null
                    ? const Center(
                        heightFactor: 40, child: Text("No Location Data"))
                    : Column(
                        children: [
                          ////////////////////
                          ////////////////////    //////////////////////
                          SingleChildScrollView(
                            child: SizedBox(
                              width: size.width,
                              height: size.height * 0.5,
                              child: ListView.builder(
                                  itemCount: locationData?.location?.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(index.toString()),
                                          Text(
                                              "lat: ${locationData?.location![index].lat}"),
                                          Text(
                                              "long: ${locationData?.location![index].long}"),
                                          Text(
                                              "Time: ${timeConvert(locationData?.location![index].time)}"),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        ],
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await db.addLocationData(latList);
          database.removeValues();
          // database.readLocationData();
          // await fetchLocationData();
        },
        tooltip: 'Increment',
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }
}
