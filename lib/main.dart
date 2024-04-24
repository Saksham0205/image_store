import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String childName, Uint8List file) async {
    try {
      Reference ref = _storage.ref().child(childName);
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return ''; // Return empty string if upload fails
    }
  }

  Future<String> saveData({
    required String name,
    required String bio,
    required Uint8List file,
  }) async {
    if (name.isNotEmpty && bio.isNotEmpty) {
      try {
        String imageUrl = await uploadImageToStorage('profileImage', file);
        await _firestore.collection("userProfile").add({
          'name': name,
          'bio': bio,
          'imageLink': imageUrl,
        });
        return 'success';
      } catch (err) {
        print("Error saving data: $err");
        return 'Error: $err';
      }
    } else {
      return "Name and Bio cannot be empty";
    }
  }
}

Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  } else {
    print("No image selected");
    return null;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController bioEditingController = TextEditingController();

  void selectImage() async {
    Uint8List? img = await pickImage(ImageSource.gallery);
    if (img != null) {
      setState(() {
        _image = img;
      });
    }
  }

  void saveProfile() async {
    String name = nameEditingController.text;
    String bio = bioEditingController.text;
    String resp = await StoreData().saveData(name: name, bio: bio, file: _image!);
    print(resp); // Print response for debugging
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Image Uploader"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                  radius: 60,
                  backgroundImage: MemoryImage(_image!),
                )
                    : const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                      "https://www.366icons.com/media/01/profile-avatar-account-icon-16699.png"),
                ),
                Positioned(
                  child: IconButton(
                    onPressed: selectImage,
                    icon: const Icon(Icons.add_a_photo),
                  ),
                  bottom: -10,
                  left: 75,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: nameEditingController,
                decoration: const InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: bioEditingController,
                decoration: const InputDecoration(
                  hintText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: saveProfile, child: const Text("Save Profile"))
          ],
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MaterialApp(
    home: HomePage(),
  ));
}