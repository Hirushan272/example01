import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example01/models/location_model.dart';
import 'package:example01/models/position_model.dart';

class FirebaseDB {
  Future<void> addLocationData(List<PositionModel> locData) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    LocationModel location = LocationModel();

    DocumentSnapshot<Map<String, dynamic>> docs =
        await db.collection("locations").doc("uid").get();

    location = LocationModel.fromMap(docs.data()!);
    location.location?.addAll(locData);
    db
        .collection("locations")
        .doc("uid")
        .update({"location": location}).then((value) {
      print('DocumentSnapshot added with');
    });
  }
}
