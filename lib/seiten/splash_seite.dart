import 'dart:async';
import 'package:flutter/material.dart';

class SplashSeite extends StatefulWidget {
  final Widget naechsteSeite;

  const SplashSeite({
    super.key,
    required this.naechsteSeite,
  });

  @override
  State<SplashSeite> createState() => _SplashSeiteState();
}

class _SplashSeiteState extends State<SplashSeite> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => widget.naechsteSeite,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Color(0xff7b2ff7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.storefront,
              size: 95,
              color: Colors.white,
            ),
            SizedBox(height: 22),
            Text(
              "Handelswelt",
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Der Marktplatz für Österreich",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 35),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}