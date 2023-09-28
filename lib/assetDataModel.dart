import 'package:cloud_firestore/cloud_firestore.dart';

class AssetDataModel {
  final String? id;
  final String? fault;

  final bool? active;
  final DateTime? shutDown;
  final DateTime? turnOn;
  final String? assetid;

  AssetDataModel( {
    this.id, this.fault, this.active, this.shutDown, this.turnOn, this.assetid,
  });

  factory AssetDataModel.fromDocument(QueryDocumentSnapshot data) {
    return AssetDataModel(
      id: data.id,
      fault: data.get('fault'),
      active: data.get('active'),
      shutDown: data.get('shutDown').toDate(),
      
      turnOn: data.get('turnOn') == null ? data.get('turnOn') : data.get('turnOn').toDate(),
      assetid: data.get('assetid'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fault': fault,
      'active': active,
      'shutDown': shutDown,
      'turnOn': turnOn,
      'assetid':assetid,
    };
  }
}
