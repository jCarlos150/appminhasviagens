import 'dart:async';

import 'package:flutter/material.dart';
import 'package:minhasViagens/home.dart';

class SplashScreann extends StatefulWidget {
  @override
  _SplashScreannState createState() => _SplashScreannState();
}

class _SplashScreannState extends State<SplashScreann> {
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => Home()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xff0066cc),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(60),
            child: Image.asset("imagens/logo.png"),
          ),
        ),
      ),
    );
  }
}
