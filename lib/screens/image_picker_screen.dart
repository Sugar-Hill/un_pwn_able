import 'dart:io';
import 'package:encrypt/encrypt.dart' as e2ee;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:un_pwn_able/screens/login_screen.dart';

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
  DateTime now = new DateTime.now();

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
    try{
      await _storage.ref().child(filePath).putFile(_imageFile).onComplete;
    }catch(e){
      Fluttertoast.showToast(
          msg: "An error has occured!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    if (_imageFile == null) {
      Fluttertoast.showToast(
          msg: "Please upload a file!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      _storage.ref().child(filePath).getDownloadURL().then((fileURL) {
        _imageFileUrl = fileURL;
        _firestore.collection('messages').add({
          'text': encrypter.encrypt(_imageFileUrl, iv: iv).base64,
          'sender': loggedInUser.email,
          'timestamp': now,
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
      Fluttertoast.showToast(
          msg: "You must be logged in to access this page!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.popAndPushNamed(context, LoginScreen.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pwned Chat',
          style: TextStyle(fontFamily: "Raleway", fontSize: 50),
        ),
        centerTitle: true,
        flexibleSpace: Image(
          image: AssetImage('images/background.jfif'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                child: Text("📂", style: TextStyle(fontSize: 30),),
                onPressed: () => _imagePicker(ImageSource.gallery),
              ),
              FlatButton(
                child: Text("📸", style: TextStyle(fontSize: 30),),
                onPressed: () => _imagePicker(ImageSource.camera),
              ),
            ],
          ),
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
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text("🚫", style: TextStyle(fontSize: 30),),
                ),
                onPressed: () {
                  _clear();
                },
              ),
              FlatButton(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text("📤", style: TextStyle(fontSize: 30)),
                ),
                onPressed: () {
                  _upload(loggedInUser);
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
