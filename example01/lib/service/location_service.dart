import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

class LocationService {
  LocationData? _locationData;

  LocationData? get locationDta => _locationData;

  Future<LocationData?> getLocation() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    location.enableBackgroundMode(enable: true);

    try {
      print("1");
      _serviceEnabled = await location.serviceEnabled();
      print("2");
      if (!_serviceEnabled) {
        print("3");
        _serviceEnabled = await location.requestService();
        print("4");
        if (!_serviceEnabled) {
          // return;

          print("Error");
        }
      }
      print("5");
      _permissionGranted = await location.hasPermission();
      print("6");
      if (_permissionGranted == PermissionStatus.denied) {
        print("7");
        _permissionGranted = await location.requestPermission();
        print("8");
        if (_permissionGranted != PermissionStatus.granted) {
          // return;
          print("Error");
        }
      }

      _locationData = await location.getLocation();
      print("TEST DATA ${_locationData?.latitude} ${_locationData?.accuracy}");
      return _locationData;
    } catch (e) {
      print("ERROR $e");
    }
    _locationData = await location.getLocation();
    return _locationData;
  }

  // double? getLocationData() {
  //   double? val;
  //   location.onLocationChanged.listen((LocationData currentLocation) {
  //     val = currentLocation.latitude;
  //   });
  //   return val;
  // }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition();
    return position;
  }
}
