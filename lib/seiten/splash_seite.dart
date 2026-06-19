import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashSeite extends StatefulWidget {
  final Widget naechsteSeite;

  const SplashSeite({
    super.key,
    required this.naechsteSeite,
  });

  @override
  State<SplashSeite> createState() => _SplashSeiteState();
}

class _SplashSeiteState extends State<SplashSeite> with TickerProviderStateMixin {
  late AnimationController _wellenController;
  late AnimationController _erscheinController;
  late Animation<double> _erscheinAnimation;

  @override
  void initState() {
    super.initState();

    _wellenController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _erscheinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _erscheinAnimation = CurvedAnimation(
      parent: _erscheinController,
      curve: Curves.easeOutCubic,
    );

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xff0d0528),
    ));

    _erscheinController.forward();

    Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.naechsteSeite,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  @override
  void dispose() {
    _wellenController.dispose();
    _erscheinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xff0d0528),
      body: Stack(
        children: [
          // Hintergrund Gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.6, -0.2),
                radius: 1.4,
                colors: [
                  Color(0xff3a1a8a),
                  Color(0xff1a0a5e),
                  Color(0xff0d0528),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Wellen-Animation
          AnimatedBuilder(
            animation: _wellenController,
            builder: (context, _) {
              return CustomPaint(
                size: size,
                painter: _WellenMaler(_wellenController.value),
              );
            },
          ),

          // Inhalt
          FadeTransition(
            opacity: _erscheinAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(_erscheinAnimation),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/logo/image_neu2.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Titel
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          "HANDELSWELT",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                            height: 1,
                          ),
                        ),
                        Text(
                          "DEALS",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Color(0xff9b7bff),
                            fontSize: 26,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Untertitel
                    const Text(
                      "Der Marktplatz für Österreich",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Ladeindikator
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WellenMaler extends CustomPainter {
  final double fortschritt;

  _WellenMaler(this.fortschritt);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Welle 1 — unten links
    _zeichneWelle(
      canvas: canvas,
      size: size,
      farbe: const Color(0xff7b2fff),
      opazitaet: 0.35,
      amplitude: h * 0.14,
      frequenz: 1.2,
      versatz: fortschritt * 2 * math.pi,
      yBasis: h * 0.72,
    );

    // Welle 2 — unten (versetzt)
    _zeichneWelle(
      canvas: canvas,
      size: size,
      farbe: const Color(0xff5b2cff),
      opazitaet: 0.25,
      amplitude: h * 0.10,
      frequenz: 1.5,
      versatz: fortschritt * 2 * math.pi + 1.2,
      yBasis: h * 0.80,
    );

    // Welle 3 — oben rechts
    _zeichneWelle(
      canvas: canvas,
      size: size,
      farbe: const Color(0xff9b5fff),
      opazitaet: 0.20,
      amplitude: h * 0.08,
      frequenz: 0.9,
      versatz: fortschritt * 2 * math.pi + 2.5,
      yBasis: h * 0.30,
      gespiegelt: true,
    );

    // Punkte
    _zeichnePunkte(canvas, size);
  }

  void _zeichneWelle({
    required Canvas canvas,
    required Size size,
    required Color farbe,
    required double opazitaet,
    required double amplitude,
    required double frequenz,
    required double versatz,
    required double yBasis,
    bool gespiegelt = false,
  }) {
    final farb = farbe.withOpacity(opazitaet);
    final pinsel = Paint()
      ..color = farb
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final pfad = Path();
    pfad.moveTo(0, yBasis);

    for (double x = 0; x <= size.width; x++) {
      final y = yBasis +
          amplitude *
              math.sin((x / size.width * frequenz * 2 * math.pi) +
                  versatz +
                  (gespiegelt ? math.pi : 0));
      pfad.lineTo(x, y);
    }

    canvas.drawPath(pfad, pinsel);
  }

  void _zeichnePunkte(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final pinsel = Paint()
      ..color = const Color(0xff9b5fff).withOpacity(0.45)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 2.0 + 0.5;
      final bewegung = math.sin(fortschritt * 2 * math.pi + i * 0.4) * 3;
      canvas.drawCircle(Offset(x, y + bewegung), r, pinsel);
    }
  }

  @override
  bool shouldRepaint(_WellenMaler alt) => alt.fortschritt != fortschritt;
}
