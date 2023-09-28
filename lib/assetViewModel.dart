import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/assetModel.dart';
import '/assets.dart';
import 'package:path/path.dart';


class AssetViewModel {
  final CollectionReference requestCollectionReference =
      FirebaseFirestore.instance.collection('assets');
  final firebase_storage.FirebaseStorage fs =
      firebase_storage.FirebaseStorage.instance;
  final DateTime dateTime = DateTime.now();

  Future<void> createAsset(
      {String? name,
      String? image,
      DateTime? created,
      String? createdby,
      bool? active,
      required BuildContext context}) async {
    AssetModel request = AssetModel(
      active: active,
      name: name,
      image: image,
      created: created,
      createdby: createdby,
    );
    requestCollectionReference.add(request.toMap()).then((value) {
      return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Assets(),
          ));
    });
    return;
  }

  Future<String> addImageForAndriod(
      XFile? file) async {
    final FirebaseStorage fs = FirebaseStorage.instance;
    String downloadURLS = "";

    final path = basename(file!.path);
    await fs
        .ref()
        .child('images/$path')
        .putFile(File(file.path))
        .then((value) {
      return value.ref.getDownloadURL().then((value) {
        downloadURLS = value.toString();
      });
    });

    return downloadURLS;
  }
}
