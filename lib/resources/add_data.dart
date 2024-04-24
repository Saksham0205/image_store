import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImagetoStorage(String childName, Uint8List file) async {
    Reference ref = _storage.ref().child(childName);
    UploadTask uploadTask = ref.putData(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({
    required String name,
    required String bio,
    required Uint8List file,
  }) async {
    String resp = "Some Error Occurred";
    if (name.isNotEmpty && bio.isNotEmpty) {
      try {
        String imageUrl = await uploadImagetoStorage('profileImage', file);
        await _firestore.collection("userProfile").add({
          'name': name,
          'bio': bio,
          'imageLink': imageUrl,
        });
        resp = 'success';
      } catch (err) {
        resp = err.toString();
      }
    } else {
      resp = "Name and Bio cannot be empty";
    }
    return resp;
  }
}
