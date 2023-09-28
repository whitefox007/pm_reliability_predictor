import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/assetDataModel.dart';

class AssetDataViewModel {
  final CollectionReference requestCollectionReference =
      FirebaseFirestore.instance.collection('assets');
  final DateTime dateTime = DateTime.now();
  Future<void> addAssetData(
      {String? fault,
      DateTime? shutDown,
      DateTime? turnOn,
      String? assetid,
      bool? active,
      required BuildContext context}) async {
    AssetDataModel request = AssetDataModel(
        active: active,
        assetid: assetid,
        fault: fault,
        shutDown: shutDown,
        turnOn: turnOn);
    requestCollectionReference
        .doc(assetid!)
        .collection('assetsData')
        .add(request.toMap());
  }

  Future<void> updateAssetData(
      {bool? active,
      String? assetid,
      String? assetDataid,
      DateTime? turnOn,
      required BuildContext context}) async {
    requestCollectionReference
        .doc(assetid)
        .collection('assetsData')
        .doc(assetDataid)
        .update({
      'turnOn': turnOn,
      'active': active,
    });
    return;
  }
}
