import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../assetDataModel.dart';

import '../assetModel.dart';

class FirebaseGet extends GetxController{
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  var assetid = 'doc'.obs;
  
  void getid(String newassetid) {
    assetid.value = newassetid;
    print(assetid.value);
  }

  Stream<List<AssetModel>> getAssets() {
    return _firebaseFirestore
        .collection('assets')
        .snapshots()
        .map((snapshot) {
      
      return snapshot.docs
          .map((doc) => AssetModel.fromDocument(doc))
          .toList();
    });
  }

  Stream<List<AssetDataModel>> getAssetDetails() {
    return _firebaseFirestore
        .collection('assets')
        .doc(assetid.value).collection('assetsData')
        .where('assetid', isEqualTo: assetid.value)
        .where('turnOn', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssetDataModel.fromDocument(doc))
          .toList();
    });
  }
  Stream<List<bool?>> getAssetsState() {
    
    return _firebaseFirestore
        .collection('assets')
        .doc(assetid.value).collection('assetsData')
        .where('assetid', isEqualTo: assetid.value)
        .where('turnOn', isNull: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AssetDataModel.fromDocument(doc).active)
          .toList();
    });
  }
  Future<void> deleteAsset(String documentId) async {
    final QuerySnapshot<Map<String, dynamic>> assetsDataSnapshot =
        await _firebaseFirestore
            .collection('assets')
            .doc(documentId)
            .collection('assetsData')
            .get();

    final List<Future<void>> futures = [];
    for (final QueryDocumentSnapshot<Map<String, dynamic>> assetDataSnapshot
        in assetsDataSnapshot.docs) {
      futures.add(assetDataSnapshot.reference.delete());
    }
    await Future.wait(futures);

    await _firebaseFirestore.collection('assets').doc(documentId).delete();
  }
}
