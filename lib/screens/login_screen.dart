import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:un_pwn_able/componenets/Home_button.dart';
import '../constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wc_form_validators/wc_form_validators.dart';


class PasswordFieldValidator{
  static String validatePassword(String value){
    if(value.isEmpty) {
      return 'Please provide a password';
    }
    return null;
  }
}

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var _formKey = GlobalKey<FormState>();
  bool showSpinner = false;
  final _auth = FirebaseAuth.instance;
  String _email;
  String _password;

  Future<void> _loginCommand() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      showSpinner = true;
      try {
        final user = await _auth.signInWithEmailAndPassword(
            email: _email, password: _password);
        if (user != null) {
          Navigator.pushNamed(context, ChatScreen.id);
        }
        setState(() {
          showSpinner = false;
        });
      } catch (e) {
        Fluttertoast.showToast(
            msg: "An error has occured please check your credentials!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIos: 3,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pwned',
          style: TextStyle(fontFamily: "Raleway", fontSize: 50),
        ),
        centerTitle: true,
        flexibleSpace: Image(
          image: AssetImage('images/background.jfif'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  validator: Validators.compose([
                    Validators.required('Please enter an email address'),
                    Validators.email('Invalid email address')
                  ]),
                  onSaved: (value) => _email = value,
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'Enter your email'),
                ),
                SizedBox(
                  height: 8.0,
                ),
                TextFormField(
                  obscureText: true,
                  textAlign: TextAlign.center,
                  // ignore: missing_return
                  validator: (value) => PasswordFieldValidator.validatePassword(value),
                  onSaved: (value) => _password = value,
                  decoration: textFieldDecoration.copyWith(
                      hintText: 'Enter your password'),
                ),
                SizedBox(
                  height: 24.0,
                ),
                HomeButton(
                    name: 'Log In',
                    colour: Colors.green,
                    onPressed: _loginCommand
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
