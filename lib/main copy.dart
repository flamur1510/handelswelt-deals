import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HandelsweltApp(),
    ),
  );
}

class HandelsweltApp extends StatefulWidget {
  const HandelsweltApp({super.key});

  @override
  State<HandelsweltApp> createState() => _HandelsweltAppState();
}

class _HandelsweltAppState extends State<HandelsweltApp> {
  String text = "Willkommen bei Handelswelt";

  void buttonDruecken() {
    setState(() {
      text = "Button wurde gedrückt!";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,

      appBar: AppBar(
        title: const Text("Handelswelt"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: buttonDruecken,
              child: const Text(
                "Klick mich",
                style: Textstyle(
                  fontSize: 20,
                  color: Colors.white,
                )
            ),
          ],
        ),
      ),
    );
  }
}