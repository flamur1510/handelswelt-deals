import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/produkt.dart';
import 'chat_seite.dart';

class DetailSeite extends StatelessWidget {
  final Produkt produkt;

  const DetailSeite({
    super.key,
    required this.produkt,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff6f3ff),

      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 320,

            pinned: true,

            backgroundColor: Colors.deepPurple,

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [

                  Image.network(
                    produkt.bild,
                    fit: BoxFit.cover,
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 20,
                    bottom: 20,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          produkt.titel,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          produkt.preis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color:
                              Colors.deepPurple
                                  .withOpacity(0.1),

                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),

                        child: Text(
                          produkt.kategorie,

                          style: const TextStyle(
                            color:
                                Colors.deepPurple,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color:
                              produkt.typ ==
                                      "Firma"
                                  ? Colors.orange
                                  : Colors.green,

                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),

                        child: Text(
                          produkt.typ,

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Beschreibung",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    produkt.beschreibung,

                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    "Standort",

                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    height: 250,

                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(22),
                    ),

                    clipBehavior: Clip.hardEdge,

                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(
                          produkt.latitude,
                          produkt.longitude,
                        ),

                        initialZoom: 14,
                      ),

                      children: [

                        TileLayer(
                          urlTemplate:
                              "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                          userAgentPackageName:
                              "com.handelswelt.app",
                        ),

                        MarkerLayer(
                          markers: [

                            Marker(
                              point: LatLng(
                                produkt.latitude,
                                produkt.longitude,
                              ),

                              width: 80,
                              height: 80,

                              child: const Icon(
                                Icons.location_on,

                                color: Colors.red,

                                size: 45,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        color: Colors.deepPurple,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          "${produkt.ort}, ${produkt.adresse}",

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.deepPurple,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  18),
                        ),
                      ),

                      onPressed: () {

                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                ChatSeite(
                              verkaeuferId:
                                  produkt.verkaeuferId,

                              verkaeuferEmail:
                                  produkt
                                      .verkaeuferEmail,

                              produktId:
                                  produkt.id,

                              produktTitel:
                                  produkt.titel,
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons.chat,
                        color: Colors.white,
                      ),

                      label: const Text(
                        "Nachricht senden",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}