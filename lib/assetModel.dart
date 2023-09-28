import 'package:cloud_firestore/cloud_firestore.dart';

class AssetModel {
  final String? id;
  final String? name;
  final bool? active;
  final String? image;
  final DateTime? created;
  final String? createdby;

  AssetModel({
    this.id,
    this.name,
    this.active,
    this.image,
    this.created,
    this.createdby,
  });

  factory AssetModel.fromDocument(QueryDocumentSnapshot data) {
    return AssetModel(
      id: data.id,
      name: data.get('name'),
      active: data.get('active'),
      image: data.get('image'),
      created: data.get('created').toDate(),
      createdby: data.get('createdby'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'active': active,
      'image': image,
      'created': created,
      'createdby': createdby,
    };
  }
}
