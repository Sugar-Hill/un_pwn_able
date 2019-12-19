import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:un_pwn_able/componenets/Home_button.dart';
import 'package:un_pwn_able/screens/registration_screen.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  static const String id = 'landing_screen';

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(seconds: 3), vsync: this);
    animation = ColorTween(begin: Colors.black, end: Colors.white)
        .animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pwned', style: TextStyle(fontFamily: "Raleway", fontSize: 50),),
        centerTitle: true,
        flexibleSpace: Image(
          image: AssetImage('images/background.jfif'),
          fit: BoxFit.cover,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                TypewriterAnimatedTextKit(
                  text: ['Don\'t Get'],
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                    fontFamily: "Raleway",
                    color: Colors.green,
                    fontSize: 50.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 100.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            HomeButton(
              name: 'Log In',
              colour: Colors.green,
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.id);
              },
            ),
            HomeButton(
              name: 'Register',
              colour: Colors.red,
              onPressed: () {
                Navigator.pushNamed(context, RegistrationScreen.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
