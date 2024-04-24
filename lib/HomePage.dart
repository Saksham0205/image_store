import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_store/resources/add_data.dart';
import 'package:image_store/utlis.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? _image;
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController bioEditingController = TextEditingController();

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void savedProfile()async {
    String name= nameEditingController.text;
    String Bio= bioEditingController.text;
    String resp = await StoreData().saveData(name: name, bio: Bio, file: _image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Image Uploader"),
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
                    : CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(
                            "https://www.366icons.com/media/01/profile-avatar-account-icon-16699.png"),
                      ),
                Positioned(
                  child: IconButton(
                    onPressed: selectImage,
                    icon: Icon(Icons.add_a_photo),
                  ),
                  bottom: -10,
                  left: 75,
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: nameEditingController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: bioEditingController,
                decoration: InputDecoration(
                  hintText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 15,),
            ElevatedButton(onPressed: savedProfile, child: Text("Save Profile"))
          ],
        ),
      ),
    );
  }
}
