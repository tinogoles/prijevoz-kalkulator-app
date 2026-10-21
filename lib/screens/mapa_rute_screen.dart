// lib/screens/mapa_rute_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/cestarine_service.dart';

class MapaRuteScreen extends StatefulWidget {
  final String polaziste;
  final String odrediste;
  final bool koristiAutocestu;

  const MapaRuteScreen({
    Key? key, 
    required this.polaziste, 
    required this.odrediste, 
    this.koristiAutocestu = true,
  }) : super(key: key);

  @override
  _MapaRuteScreenState createState() => _MapaRuteScreenState();
}

class _MapaRuteScreenState extends State<MapaRuteScreen> {
  final CestarineService _cestarineService = CestarineService();
  List<LatLng> _tockeRute = [];
  bool _ucitavanje = true;

  @override
  void initState() {
    super.initState();
    _ucitajMapu();
  }

  Future<void> _ucitajMapu() async {
    List<LatLng> tocke = await _cestarineService.dohvatiGeometrijuRute(
      widget.polaziste, 
      widget.odrediste, 
      koristiAutocestu: widget.koristiAutocestu,
    );
    setState(() {
      _tockeRute = tocke;
      _ucitavanje = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta: ${widget.polaziste} -> ${widget.odrediste}'),
        backgroundColor: Colors.orange,
      ),
      body: _ucitavanje
          ? const Center(child: CircularProgressIndicator())
          : _tockeRute.isEmpty
              ? const Center(child: Text('Nije moguće učitati kartu rute za ove lokacije.'))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _tockeRute[(_tockeRute.length / 2).floor()],
                    initialZoom: 7.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.prijevoz_kalkulator',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _tockeRute,
                          color: Colors.deepOrange,
                          strokeWidth: 5.0,
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
