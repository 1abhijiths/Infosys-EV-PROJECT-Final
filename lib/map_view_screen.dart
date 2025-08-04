import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'charging_station_screen.dart';
import 'review_dialog.dart';

class MapViewScreen extends StatelessWidget {
  final LatLng startLocation;
  final LatLng destinationLocation;
  final List<ChargingStation> chargingStations;
  final String startLocationName;
  final String destinationLocationName;

  const MapViewScreen({
    Key? key,
    required this.startLocation,
    required this.destinationLocation,
    required this.chargingStations,
    required this.startLocationName,
    required this.destinationLocationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route Map'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.rate_review),
            onPressed: () => _showReviewDialog(context),
            tooltip: 'Add Review',
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: _calculateCenterPoint(),
          zoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ev_charging_app',
          ),
          MarkerLayer(
            markers: _buildMarkers(context),
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: [startLocation, destinationLocation],
                color: Colors.blue,
                strokeWidth: 3.0,
                isDotted: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => ReviewDialog(
        stations: chargingStations,
        preSelectedStation: chargingStations.first,
      ),
    );
  }

  LatLng _calculateCenterPoint() {
    List<LatLng> allPoints = [startLocation, destinationLocation];
    for (var station in chargingStations) {
      if (station.location != null) {
        allPoints.add(station.location!);
      }
    }

    double avgLat = allPoints.map((p) => p.latitude).reduce((a, b) => a + b) / allPoints.length;
    double avgLng = allPoints.map((p) => p.longitude).reduce((a, b) => a + b) / allPoints.length;

    return LatLng(avgLat, avgLng);
  }

  List<Marker> _buildMarkers(BuildContext context) {
    List<Marker> markers = [];

    // Start location marker
    markers.add(
      Marker(
        width: 60,
        height: 60,
        point: startLocation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Icon at the bottom
            Positioned(
              left: 17.5,
              bottom: 0,
              child: Icon(Icons.location_on, color: Colors.green, size: 25),
            ),
            // Label above
            Positioned(
              bottom: 20,
              left: -20,
              right: -20,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'START',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Destination marker
    markers.add(
      Marker(
        width: 60,
        height: 60,
        point: destinationLocation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Icon at the bottom
            Positioned(
              left: 17.5,
              bottom: 0,
              child: Icon(Icons.flag, color: Colors.red, size: 25),
            ),
            // Label above
            Positioned(
              bottom: 20,
              left: -20,
              right: -20,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'END',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Charging station markers
    for (var station in chargingStations) {
      if (station.location != null) {
        final bool isSwap = station.isBatterySwapping;
        final Color markerColor = station.isRenewablePowered ? Colors.orange : Colors.blue;
        
        markers.add(
          Marker(
            width: 60,
            height: 60,
            point: station.location!,
            child: GestureDetector(
              onTap: () => _showStationInfo(context, station),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icon at the bottom
                  Positioned(
                    left: 17.5,
                    bottom: 0,
                    child: Icon(
                      isSwap ? Icons.swap_horiz : Icons.electric_bolt,
                      color: markerColor,
                      size: 25,
                    ),
                  ),
                  // Label above
                  Positioned(
                    bottom: 20,
                    left: -20,
                    right: -20,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: markerColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isSwap ? 'SWAP' : 'CHARGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  void _showStationInfo(BuildContext context, ChargingStation station) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    station.isBatterySwapping ? Icons.swap_horiz : Icons.electric_bolt,
                    color: station.isRenewablePowered ? Colors.orange : Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      station.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.rate_review),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => ReviewDialog(
                          stations: chargingStations,
                          preSelectedStation: station,
                        ),
                      );
                    },
                    tooltip: 'Review this station',
                  ),
                  if (station.isRenewablePowered)
                    Icon(Icons.eco, color: Colors.green),
                ],
              ),
              SizedBox(height: 8),
              Text(station.address, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16),
                  Text('${station.distance} km away'),
                  SizedBox(width: 16),
                  Icon(Icons.star, size: 16, color: Colors.orange),
                  Text('${station.rating}/5.0'),
                ],
              ),
              if (station.isRenewablePowered) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${station.renewableEnergyType} powered - ${station.co2Reduction} kg CO₂ saved',
                          style: TextStyle(color: Colors.green[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
