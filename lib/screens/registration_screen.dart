import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:un_pwn_able/componenets/Home_button.dart';
import '../constants.dart';
import 'chat_screen.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wc_form_validators/wc_form_validators.dart';


class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  var _formKey = GlobalKey<FormState>();

  final _auth = FirebaseAuth.instance;
  final _passwordController = TextEditingController();
  bool showSpinner = false;
  String _email;
  String _password;

  void _submitCommand() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      _registrationCommand();
    }
  }

  Future<void> _registrationCommand() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      showSpinner = true;
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        if (newUser != null) {
          Navigator.pushNamed(context, ChatScreen.id);
        }
        setState(() {
          showSpinner = false;
        });
      }on PlatformException catch(e){
        setState(() {
          showSpinner = false;
          Fluttertoast.showToast(
              msg: "This email is in use choose another one!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
      catch (e) {
        setState(() {
          showSpinner = false;
          print(e);
          Fluttertoast.showToast(
              msg: "An error has occured pleased check the fields!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIos: 3,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
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
//        backgroundColor: Colors.black,
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
                        height: 300.0,
                        child: Image.asset('images/logo.png'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  //TextFormField enables us to apply the validation layer on our text field
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    validator: Validators.compose([
                      Validators.required('Please enter an email address'),
                      Validators.email(
                          'Invalid email address, please use the form - test@example.com')
                    ]),
                    onSaved: (value) => _email = value,
                    decoration: textFieldDecoration.copyWith(
                        hintText: 'Enter your email'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    validator: Validators.compose([
                      Validators.required('Please enter a password'),
                      Validators.minLength(8,
                          'Your password must be at least 8 characters long'),
                      Validators.maxLength(128,
                          'Your password cannot be more than 128 characters long'),
                      Validators.patternString('(?=.*[A-Z])',
                          'Your password must contain at least 1 uppercase letter'),
                      Validators.patternString('(?=.*\\d)',
                          'Your password must contain at least 1 digit'),
                      Validators.patternString('(?=.*[a-z])',
                          'Your password must contain at least 1 lowercase letter'),
                      Validators.patternString('(?=.*[@#%&])',
                          'Your password must contain at least 1 special character - [@, #, % or &]')
                    ]),
                    decoration: textFieldDecoration.copyWith(
                        hintText: 'Enter your password'),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    // ignore: missing_return
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please confirm your password';
                      } else if (value != _passwordController.text) {
                        return 'Your passwords do not match';
                      }
                    },
                    onSaved: (value) => _password = value,
                    decoration: textFieldDecoration.copyWith(
                        hintText: 'Confirm password'),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  HomeButton(
                      name: 'Register',
                      colour: Colors.red,
                      onPressed: _submitCommand),
                ],
              ),
            ),
          ),
        ));
  }
}
