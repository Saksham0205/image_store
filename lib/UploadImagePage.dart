import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({Key? key}) : super(key: key);

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
   XFile? imageFile;

  Future<void> pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedImage != null) {
        imageFile = XFile(pickedImage.path);
      } else {
        print("No image selected");
      }
    });
  }

  Future<void> uploadImage() async {
    if (imageFile == null) {
      print("No image selected");
      return;
    }
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference storageReference = storage.ref().child('images/${DateTime.now()}.png');
    UploadTask uploadTask = storageReference.putFile(File(imageFile!.path));
    await uploadTask.whenComplete(() => print('Image uploaded to Firebase Storage'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Image to Firebase"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imageFile != null ? Image.file(File(imageFile!.path), height: 200) : Text("No image selected"),
            SizedBox(height: 20),
            ElevatedButton(onPressed: pickImage, child: Text("Pick Image")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: uploadImage, child: Text("Upload image to Firebase")),
          ],
        ),
      ),
    );
  }
}
