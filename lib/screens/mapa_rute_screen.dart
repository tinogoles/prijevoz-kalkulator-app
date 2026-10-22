// lib/screens/mapa_rute_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapaRuteScreen extends StatefulWidget {
  final String polaziste;
  final String odrediste;
  final bool koristiAutocestu;
  final Map<String, double>? polazisteCoords;
  final Map<String, double>? odredisteCoords;

  const MapaRuteScreen({
    Key? key, 
    required this.polaziste, 
    required this.odrediste, 
    this.koristiAutocestu = true,
    this.polazisteCoords,
    this.odredisteCoords,
  }) : super(key: key);

  @override
  _MapaRuteScreenState createState() => _MapaRuteScreenState();
}

class _MapaRuteScreenState extends State<MapaRuteScreen> {
  List<LatLng> _tockeRute = [];
  bool _ucitavanje = true;

  @override
  void initState() {
    super.initState();
    _ucitajMapu();
  }

  Future<Map<String, double>?> _dohvatiKoordinate(String naziv) async {
    String upit = naziv.trim();
    if (upit.contains(',')) {
      upit = upit.split(',')[0].trim(); // Uzmi samo glavni naziv (npr. Podgrađe ili Split)
    }
    if (!upit.toLowerCase().contains('hrvatska')) {
      upit = '$upit, Hrvatska';
    }

    try {
      final res = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(upit)}&format=json&limit=1'),
        headers: {'User-Agent': 'PrijevozKalkulatorApp'},
      );
      if (res.statusCode == 200) {
        List data = json.decode(res.body);
        if (data.isNotEmpty) {
          return {
            'lat': double.parse(data[0]['lat']),
            'lon': double.parse(data[0]['lon']),
          };
        }
      }
    } catch (e) {
      print('Greška geokodiranja za mapu: $e');
    }
    return null;
  }

  Future<void> _ucitajMapu() async {
    try {
      // 1. Dobij koordinate polazišta (koristi proslijeđene ili ih dohvati)
      Map<String, double>? pCoords = widget.polazisteCoords;
      if (pCoords == null) {
        pCoords = await _dohvatiKoordinate(widget.polaziste);
      }

      // 2. Dobij koordinate odredišta
      Map<String, double>? oCoords = widget.odredisteCoords;
      if (oCoords == null) {
        oCoords = await _dohvatiKoordinate(widget.odrediste);
      }

      if (pCoords != null && oCoords != null) {
        // 3. Pozovi OSRM servis za geometriju rute
        String url = 'https://router.project-osrm.org/route/v1/driving/${pCoords['lon']},${pCoords['lat']};${oCoords['lon']},${oCoords['lat']}?overview=full&geometries=geojson';
        
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['code'] == 'Ok') {
            List coordsList = data['routes'][0]['geometry']['coordinates'];
            setState(() {
              _tockeRute = coordsList.map((c) => LatLng(c[1], c[0])).toList();
              _ucitavanje = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      print('Greška pri učitavanju rute na mapi: $e');
    }

    setState(() {
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
                    initialZoom: 8.0,
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
