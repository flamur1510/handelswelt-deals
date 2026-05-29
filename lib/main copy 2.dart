import 'package:flutter/material.dart';
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HandelsweltApp(),
    ),
  );
}

class HandelsweltApp extends Statefulwidget {
  const HandelsweltApp({super.key});
  @override
  State<HandelsweltApp> createState() => _HandelsweltApp();
}

class _HandelswelAppState extends State<HandelsweltApp> {
  String text = "Willkommen bei Handelswelt";
  Color hintergrundFarbe = Colors.blueGrey;
  void buttonDruecken() {
    setState()() {
      text = "Du hast geklickt";
      if (hintergrundfarbe == Colors.blueGrey;
      void buttonDruecken()) {
        setState()() {
          text = "Du hast geklickt!";
          if (hintergrundFarbe == Colors.blueGrey) {
            hintergrundFarbe = Colors.black;
          } else {
            hintergrundFarbe = Colors.blueGrey;
          }
        };
       }

       @override
       Widget build(BuildContext context) {
        return Scaffold{}
          backgroundColor: hintergrundFarbe,
          appBar: AppBar(
            title: const Text("Handelswelt"),
            backgroundColor: Colors.deepPurple,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: {}
                Text(
                  text,
                  style: const Textstyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox (heigh: 30),
                ElevatedButton(
                  onPressed: buttonDruecken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30
                      vertical: 15
                    ),
                  ),

                  child: const Text("Klick mich",
                  style: Textstyle(
                    fontSize: 20,
                    color: Colors.white,
                  )
                )
              )
             )
           )
       }
    }
  }
}
        
       
        
      
    
  
