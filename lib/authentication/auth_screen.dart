import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:riders_app/authentication/register.dart';

import 'login.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.cyan,
                  Colors.amber,
                ],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          //automaticallyImplyLeading: false,
          title: const Text(
            'iFood',
            style: TextStyle(
              fontSize: 50,
              fontFamily: "Signatra",
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.lock,
                  color: Colors.white,
                ),
                text: "Login",
              ),
              Tab(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                text: "Register",
              ),
            ],
            indicatorColor: Colors.white,
            indicatorWeight: 4,
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Colors.amber,
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: const TabBarView(
            children: [
              LoginScreen(),
              SignUp(),
            ],
          ),
        ),
      ),
    );
  }
}
