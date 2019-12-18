import 'dart:io';
import 'package:encrypt/encrypt.dart' as e2ee;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

final _firestore = Firestore.instance;
FirebaseUser loggedInUser;

class ImagePickerScreen extends StatefulWidget {
  static const String id = 'image_picker_screen';

  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final _auth = FirebaseAuth.instance;
  File _imageFile;
  String _imageFileUrl;
  Future<void> _imagePicker(ImageSource imageSource) async {
    File selected = await ImagePicker.pickImage(source: imageSource);

    setState(() {
      _imageFile = selected;
    });
  }

  void _clear() {
    setState(() => _imageFile = null);
  }

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://un-pwn-able.appspot.com/');

  void _upload() async {
    final key = e2ee.Key.fromLength(32);
    final iv = e2ee.IV.fromLength(16);
    final encrypter = e2ee.Encrypter(e2ee.AES(key));
    String filePath = 'images/${DateTime.now()}';
    await _storage.ref().child(filePath).putFile(_imageFile).onComplete;
    if(_imageFile == null){
      print("nopeeeeeeeeeeeeeee");
    }else{
      _storage.ref().child(filePath).getDownloadURL().then((fileURL) {
        _imageFileUrl = fileURL;
        print(_imageFileUrl);
        _firestore.collection('messages').add({
          'text': encrypter
              .encrypt(_imageFileUrl, iv: iv)
              .base64,
          'sender': loggedInUser.email,
          'timestamp': DateTime.now(),
          'isImage': true,

        });

      });


    }

  }
  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.photo_camera,
                size: 30,
              ),
              onPressed: () => _imagePicker(ImageSource.camera),
              color: Colors.yellow,
            ),
            IconButton(
              icon: Icon(
                Icons.photo_library,
                size: 30,
              ),
              onPressed: () => _imagePicker(ImageSource.gallery),
              color: Colors.yellow,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: chosenImage(_imageFile),
        ),
      ),
    );
  }

  Widget chosenImage(File image) {

    if (image == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: Center(child: Text("Please Choose an Image")),
              width: double.infinity,
              height: 300,
              color: Colors.grey,
            ),
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(child: Image.file(_imageFile)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                color: Colors.yellow,
                child: Icon(Icons.refresh),
                onPressed: () {
                  _clear();
                },
              ),
              FlatButton(
                color: Colors.yellow,
                child: Icon(Icons.send),
                onPressed: () {
                  _upload();
                  Navigator.pop(context);

                  },
              ),
            ],
          ),
        ],
      );
    }
  }
}
