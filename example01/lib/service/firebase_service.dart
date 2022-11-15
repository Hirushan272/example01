import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:example01/models/location_model.dart';
import 'package:example01/models/position_model.dart';

class FirebaseDB {
  CollectionReference db = FirebaseFirestore.instance.collection("locations");

  Future<void> addLocationData(List<PositionModel> locData) async {
    LocationModel location = LocationModel();

    DocumentSnapshot docs = await db.doc("uid").get();
    final data = docs.data() as Map<String, dynamic>;
    location = LocationModel.fromMap(data);
    location.location?.addAll(locData);
    db.doc("uid").update({"location": location}).then((value) {
      print('DocumentSnapshot added with');
    });
  }
}
