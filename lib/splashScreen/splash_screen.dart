import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:riders_app/global/global.dart';

import '../authentication/auth_screen.dart';
import '../mainScreens/home_screen.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 3), () async {
      //  Navigator.push(context,
      //     MaterialPageRoute(builder: ((context) => const AuthScreen())));
      //if rider is logged in already 
      if(firebaseAuth.currentUser != null) {
         Navigator.push(context,
          MaterialPageRoute(builder: ((context) => const HomeScreen())));
      }
      else{
         Navigator.push(context,
          MaterialPageRoute(builder: ((context) => const AuthScreen())));
       }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    //imageCache.clear();
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, 
            children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('images/logo.png'),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.all(18.0),
              child: Text(
                'Order food online made easier',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 40,
                  fontFamily: 'Signatra',
                  letterSpacing: 3,
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
