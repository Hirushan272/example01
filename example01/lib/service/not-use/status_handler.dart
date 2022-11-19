// import 'package:background_location_tracker/background_location_tracker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class StatusHandler {
//   static bool? isTracking;
//   Future<void> _getTrackingStatus() async {
//     isTracking = await BackgroundLocationTrackerManager.isTracking();
//     // setState(() {});
//   }

//   Future<void> _requestLocationPermission() async {
//     final result = await Permission.locationAlways.request();
//     if (result == PermissionStatus.granted) {
//       print('GRANTED'); // ignore: avoid_print
//     } else {
//       await Permission.locationAlways.request();
//       print('NOT GRANTED'); // ignore: avoid_print
//     }
//   }

//   Future<void> _requestNotificationPermission() async {
//     final result = await Permission.notification.request();
//     if (result == PermissionStatus.granted) {
//       print('GRANTED'); // ignore: avoid_print
//     } else {
//       print('NOT GRANTED'); // ignore: avoid_print
//     }
//   }
// }
