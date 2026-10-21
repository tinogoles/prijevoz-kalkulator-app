import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/cestarine_service.dart';

class MapaRuteScreen extends StatefulWidget {
  final String polaziste;
  final String odrediste;

  const MapaRuteScreen({Key? key, required this.polaziste, required this.odrediste}) : super(key: key);

  @override
  _MapaRuteScreenState createState() => _MapaRuteScreenState();
}

class _MapaRuteScreenState extends State<MapaRuteScreen> {
  final CestarineService _cestarineService = CestarineService();
  List<LatLng> _točkeRute = [];
  bool _ucitavanje = true;

  @override
  void initState() {
    super.initState();
    _ucitajMapu();
  }

  Future<void> _ucitajMapu() async {
    List<LatLng> tocke = await _cestarineService.dohvatiGeometrijuRute(widget.polaziste, widget.odrediste);
    setState(() {
      _točkeRute = tocke;
      _ucitavanje = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta: ${widget.polaziste} -> ${widget.odrediste}'),
      ),
      body: _ucitavanje
          ? const Center(child: CircularProgressIndicator())
          : _točkeRute.isEmpty
              ? const Center(child: Text('Nije moguće učitati kartu rute.'))
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _točkeRute[(_točkeRute.length / 2).floor()],
                    initialZoom: 7.0,
                  ),
                  children: [
                    // OpenStreetMap pozadinske pločice (besplatno)
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.prijevoz_kalkulator',
                    ),
                    // Iscrtavanje linije rute
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _točkeRute,
                          color: Colors.orange,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
