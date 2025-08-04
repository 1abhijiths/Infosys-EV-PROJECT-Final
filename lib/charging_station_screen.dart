import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Note: Add these dependencies to your pubspec.yaml:
// flutter_map: ^6.1.0
// latlong2: ^0.8.1

// The 'ChargingStation' class serves as the data model for charging stations.
class ChargingStation {
  final String name;
  final String address;
  final double distance;
  final double chargingSpeed;
  final double estimatedTime;
  final List<String> connectorTypes;
  final bool isCompatible;
  final double rating;
  final int reviews;
  final bool isBatterySwapping;
  final int availableBatteries;
  final List<String> compatibleModels;
  final double co2Reduction;
  final bool isRenewablePowered;
  final String renewableEnergyType;
  final bool supportsCommunity;
  final String communityBenefits;
  final LatLng? location; // Added location coordinates

  const ChargingStation({
    required this.name,
    required this.address,
    required this.distance,
    required this.chargingSpeed,
    required this.estimatedTime,
    required this.connectorTypes,
    required this.isCompatible,
    required this.rating,
    required this.reviews,
    required this.isBatterySwapping,
    required this.availableBatteries,
    required this.compatibleModels,
    required this.co2Reduction,
    required this.isRenewablePowered,
    required this.renewableEnergyType,
    required this.supportsCommunity,
    required this.communityBenefits,
    this.location,
  });

  // Factory constructor to create a ChargingStation instance from a JSON object.
  factory ChargingStation.fromJson(Map<String, dynamic> json) {
    LatLng? location;
    if (json['latitude'] != null && json['longitude'] != null) {
      location = LatLng(
        double.parse(json['latitude'].toString()),
        double.parse(json['longitude'].toString())
      );
    }

    return ChargingStation(
      name: json['name'] ?? 'Unknown Station',
      address: json['address'] ?? 'Address not available',
      distance: (json['distance'] ?? 0.0).toDouble(),
      chargingSpeed: (json['chargingSpeed'] ?? 0.0).toDouble(),
      estimatedTime: (json['estimatedTime'] ?? 0.0).toDouble(),
      connectorTypes: List<String>.from(json['connectorTypes'] ?? []),
      isCompatible: json['isCompatible'] ?? false,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      isBatterySwapping: json['isBatterySwapping'] ?? false,
      availableBatteries: json['availableBatteries'] ?? 0,
      compatibleModels: List<String>.from(json['compatibleModels'] ?? []),
      co2Reduction: (json['co2Reduction'] ?? 0.0).toDouble(),
      isRenewablePowered: json['isRenewablePowered'] ?? false,
      renewableEnergyType: json['renewableEnergyType'] ?? '',
      supportsCommunity: json['supportsCommunity'] ?? false,
      communityBenefits: json['communityBenefits'] ?? '',
      location: location,
    );
  }
}

class ChargingStationHomePage extends StatefulWidget {
  @override
  _ChargingStationHomePageState createState() =>
      _ChargingStationHomePageState();
}

class _ChargingStationHomePageState extends State<ChargingStationHomePage> {
  // API Key has been added as requested.
  static const String _apiKey = 'AIzaSyBYUpIEWXpF3HfZXSQayTKvgfQBqUFUDWI';

  String _selectedVehicleType = 'Tesla';
  String _selectedPriority = 'Fastest Service';
  String _selectedServiceType = 'Both';
  bool _prioritizeRenewable = false;
  bool _showSDGMode = true;
  bool _isLoading = false;
  List<ChargingStation> _recommendations = [];
  double _totalCO2Saved = 0;
  double _renewableEnergyUsed = 0;
  int _sustainableTrips = 0;
  LatLng? _startLocation;
  LatLng? _destinationLocation;

  final List<String> _vehicleTypes = [
    'Tesla', 'Nissan Leaf', 'Chevrolet Bolt', 'BMW i3', 'Audi e-tron',
    'Hyundai Kona Electric', 'Ford Mustang Mach-E', 'Volkswagen ID.4',
    'NIO ES8', 'NIO ES6', 'Gogoro Scooter', 'Other CCS', 'Other CHAdeMO'
  ];

  final List<String> _priorities = [
    'Fastest Service', 'Shortest Detour', 'Most Amenities', 'Highest Rated',
    'Cheapest Price', 'Greenest Energy', 'Community Impact'
  ];

  final List<String> _serviceTypes = ['Both', 'Charging Only', 'Battery Swapping Only'];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  // Calculates a recommendation score for a station based on various factors and UI settings.
  double _calculateStationScore(ChargingStation station) {
    // Base score starts at 100 and decreases with distance.
    double score = 100 - (station.distance * 5); // Lose 5 points per km

    // Major bonus for renewable energy, especially when SDG mode is on.
    if (station.isRenewablePowered) {
      score += _showSDGMode ? 100 : 50; // Double bonus in SDG mode
      score += (station.co2Reduction / 2); // Additional bonus for CO2 reduction
    }

    if (station.isCompatible) score += 20;
    if (station.supportsCommunity) score += 10;
    
    // Bonus for good ratings and number of reviews.
    score += (station.rating - 3.5) * 10;
    score += (station.reviews > 200 ? 10 : station.reviews / 20);

    // Bonus for charging speed or battery availability.
    if (station.isBatterySwapping) {
      score += (station.availableBatteries > 10 ? 15 : station.availableBatteries);
    } else {
      score += (station.chargingSpeed / 10);
    }

    return score;
  }

  // **FIXED OVERFLOW**: Helper method to build a consistent info item row.
  // Wrapped the Text widget in a Flexible widget to prevent layout overflows.
  Widget _buildInfoItem(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      SizedBox(width: 4),
      Flexible(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    // The main scaffold and UI structure.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Hero(
          tag: 'app_title',
          child: Text('Sustainable EV Journey Planner'),
        ),
        backgroundColor: Colors.green[700]?.withOpacity(0.85),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: IconButton(
              key: ValueKey(_showSDGMode),
              icon: Icon(_showSDGMode ? Icons.eco : Icons.eco_outlined),
              onPressed: () {
                setState(() {
                  _showSDGMode = !_showSDGMode;
                });
              },
              tooltip: 'Toggle SDG Mode',
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedGradientBackground(),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 700),
                  child: _showSDGMode ? _buildSDGHeader() : SizedBox.shrink(),
                ),
                if (_showSDGMode) SizedBox(height: 20),
                AnimatedCard(child: _buildDestinationInputs()),
                SizedBox(height: 20),
                AnimatedCard(child: _buildVehicleSelection()),
                SizedBox(height: 20),
                AnimatedCard(child: _buildServiceTypeSelection()),
                SizedBox(height: 20),
                AnimatedCard(child: _buildPrioritySelection()),
                if (_showSDGMode) SizedBox(height: 20),
                if (_showSDGMode) AnimatedCard(child: _buildSustainabilityOptions()),
                SizedBox(height: 30),
                AnimatedSearchButton(isLoading: _isLoading, onPressed: _searchChargingStations),
                SizedBox(height: 30),
                if (_showSDGMode) AnimatedCard(child: _buildSDGImpactTracker()),
                if (_showSDGMode) SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 700),
                  child: _buildRecommendations(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSDGHeader() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.public, color: Colors.green[700], size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Supporting UN Sustainable Development Goals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSDGBadge('SDG 7', 'Clean Energy', Icons.wb_sunny, Colors.orange),
                _buildSDGBadge('SDG 11', 'Sustainable Cities', Icons.location_city, Colors.blue),
                _buildSDGBadge('SDG 13', 'Climate Action', Icons.eco, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSDGBadge(String sdg, String title, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + 0.2 * value,
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  sdg,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSustainabilityOptions() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sustainability Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Prioritize Renewable Energy Sources'),
              subtitle: Text('Choose stations powered by solar, wind, or other clean energy'),
              value: _prioritizeRenewable,
              onChanged: (bool? value) {
                setState(() {
                  _prioritizeRenewable = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSDGImpactTracker() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[700]),
                SizedBox(width: 8),
                Text(
                  'Your Environmental Impact',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImpactCard(
                    'CO₂ Saved',
                    '${_totalCO2Saved.toStringAsFixed(1)} kg',
                    Icons.cloud_off,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildImpactCard(
                    'Renewable Energy',
                    '${_renewableEnergyUsed.toStringAsFixed(1)} kWh',
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildImpactCard(
                    'Sustainable Trips',
                    '$_sustainableTrips',
                    Icons.directions_car,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationInputs() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trip Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _startController,
              decoration: InputDecoration(
                hintText: 'Enter starting location',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _endController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vehicle Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedVehicleType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: _vehicleTypes.map((type) => DropdownMenuItem(
                value: type,
                child: Text(type),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTypeSelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedServiceType,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.swap_horiz),
              ),
              items: _serviceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedServiceType = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: _priorities.map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Row(
                    children: [
                      Text(priority),
                      if (priority == 'Greenest Energy' || priority == 'Community Impact')
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.eco, size: 16, color: Colors.green),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // **UPDATED SORTING LOGIC**
  Widget _buildRecommendations() {
    if (_recommendations.isEmpty && !_isLoading) {
      return SizedBox.shrink();
    }

    List<ChargingStation> displayRecommendations = List.from(_recommendations);

    // Apply the new sorting logic based on user's preference
    displayRecommendations.sort((a, b) {
      if (_prioritizeRenewable) {
        // 1. Primary sort: renewable vs. non-renewable
        if (a.isRenewablePowered && !b.isRenewablePowered) return -1; // a comes first
        if (!a.isRenewablePowered && b.isRenewablePowered) return 1;  // b comes first

        // 2. Secondary sort: by distance (closest first)
        return a.distance.compareTo(b.distance);
      } else {
        // Fallback to original score-based sorting
        double aScore = _calculateStationScore(a);
        double bScore = _calculateStationScore(b);
        return bScore.compareTo(aScore); // Higher score first
      }
    });

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended Stations',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_startLocation != null && _destinationLocation != null && _recommendations.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: _showMapView,
                    icon: Icon(Icons.map, size: 20),
                    label: Text('View Map'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            ...displayRecommendations.map((station) => _buildStationCard(station)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(ChargingStation station) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: station.isRenewablePowered
          ? RoundedRectangleBorder(
              side: BorderSide(color: Colors.green[700]!, width: 2),
              borderRadius: BorderRadius.circular(12),
            )
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  station.isCompatible ? Icons.check_circle : Icons.warning,
                  color: station.isCompatible ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              station.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (station.isRenewablePowered)
                            Icon(Icons.eco, color: Colors.green[700]),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showStationOnMap(station),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        station.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // Service badges row with wrapping
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Service type badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: station.isBatterySwapping ? Colors.blue[100] : Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    station.isBatterySwapping ? 'SWAP' : 'CHARGE',
                    style: TextStyle(
                      color: station.isBatterySwapping ? Colors.blue[800] : Colors.green[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (station.isRenewablePowered)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '100% RENEWABLE',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (station.supportsCommunity)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'COMMUNITY+',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12),
            // Info grid
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildInfoItem(Icons.location_on, '${station.distance} km'),
                  if (station.isBatterySwapping) ...[
                    _buildInfoItem(Icons.swap_horiz, '${station.estimatedTime} min swap'),
                    _buildInfoItem(Icons.battery_full, '${station.availableBatteries} batteries'),
                  ] else ...[
                    _buildInfoItem(Icons.electric_bolt, '${station.chargingSpeed} kW'),
                    _buildInfoItem(Icons.access_time, '${station.estimatedTime} min'),
                  ],
                  _buildInfoItem(Icons.star, '${station.rating.toStringAsFixed(1)}/5.0'),
                  _buildInfoItem(Icons.rate_review, '${station.reviews} reviews'),
                ],
              ),
            ),
            if (_showSDGMode) ...[
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Environmental Impact',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoItem(Icons.eco, '${station.co2Reduction.toStringAsFixed(1)} kg CO₂ saved'),
                        if (station.isRenewablePowered)
                          _buildInfoItem(Icons.wb_sunny, station.renewableEnergyType),
                      ],
                    ),
                    if (station.supportsCommunity) ...[
                      SizedBox(height: 8),
                      _buildInfoItem(Icons.people, station.communityBenefits),
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 8),
            if (station.isBatterySwapping)
              Text(
                'Compatible: ${station.compatibleModels.take(4).join(', ')}${station.compatibleModels.length > 4 ? ', ...' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              )
            else
              Text(
                'Connectors: ${station.connectorTypes.take(4).join(', ')}${station.connectorTypes.length > 4 ? ', ...' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            if (!station.isCompatible) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Not compatible with your vehicle',
                  style: TextStyle(color: Colors.orange[800], fontSize: 12),
                ),
              ),
            ],
          ],
        ),),
      );
  }

  void _showMapView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapViewScreen(
          startLocation: _startLocation!,
          destinationLocation: _destinationLocation!,
          chargingStations: _recommendations,
          startLocationName: _startController.text,
          destinationLocationName: _endController.text,
        ),
      ),
    );
  }

  void _showStationOnMap(ChargingStation station) {
    if (station.location != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SingleStationMapView(
            station: station,
            startLocation: _startLocation,
            destinationLocation: _destinationLocation,
          ),
        ),
      );
    } else {
      _showSnackBar('Location coordinates not available for this station');
    }
  }

  Future<void> _searchChargingStations() async {
    if (_startController.text.isEmpty || _endController.text.isEmpty) {
      _showSnackBar('Please enter both starting location and destination');
      return;
    }

    setState(() {
      _isLoading = true;
      _recommendations.clear();
    });

    try {
      // Get coordinates for start and destination
      _startLocation = await _getCoordinatesFromAddress(_startController.text);
      _destinationLocation = await _getCoordinatesFromAddress(_endController.text);
      
      final recommendations = await _getChargingStationRecommendations();
      setState(() {
        _recommendations = recommendations;
        _updateSDGMetrics(); // Update impact metrics after getting new recommendations
      });
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
      // Fallback to mock data on API error to ensure a good user experience.
      setState(() {
        _recommendations = _createMockStations();
        // Set mock coordinates for demo purposes
        _startLocation = LatLng(17.3850, 78.4867); // Hyderabad
        _destinationLocation = LatLng(17.4065, 78.4772); // Nearby location
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<LatLng> _getCoordinatesFromAddress(String address) async {
    // Using Nominatim (OpenStreetMap) geocoding service
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?format=json&q=$encodedAddress&limit=1'),
        headers: {'User-Agent': 'EV Charging Station App'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
    
    // Fallback coordinates (Hyderabad center)
    return LatLng(17.3850, 78.4867);
  }

  void _updateSDGMetrics() {
    double co2Saved = 0;
    double renewableEnergy = 0;

    for (var station in _recommendations) {
      co2Saved += station.co2Reduction;
      if (station.isRenewablePowered) {
        // Approximate energy used: speed (kW) * time (hours)
        renewableEnergy += station.chargingSpeed * (station.estimatedTime / 60);
      }
    }

    setState(() {
      _totalCO2Saved += co2Saved;
      _renewableEnergyUsed += renewableEnergy;
      if (_recommendations.isNotEmpty) {
        _sustainableTrips += 1;
      }
    });
  }

  Future<List<ChargingStation>> _getChargingStationRecommendations() async {
    final sustainabilityContext = _prioritizeRenewable || _showSDGMode ? 
      'Must prioritize stations using renewable energy sources (solar, wind, hydro). The first station MUST be renewable-powered if possible.' : 
      'Include a mix of conventional and renewable energy stations.';
    
    final sdgContext = _showSDGMode ? 
      'For each station, include SDG-related information like estimated CO2 reduction in kg, the type of renewable energy used (if any), and any community benefits.' : 
      '';

    final prompt = '''
    I need exactly 3 JSON objects for an EV charging station recommendation app.
    
    Trip Details:
    - Starting Location: ${_startController.text}
    - Destination: ${_endController.text}
    - Vehicle Type: $_selectedVehicleType
    - User Priority: $_selectedPriority
    - Service Type: $_selectedServiceType
    - Sustainability Focus: $sustainabilityContext
    - Extra Context: $sdgContext

    Generate 3 realistic station recommendations with GPS coordinates. The response must be ONLY a valid JSON array of objects.
    Adhere to this JSON schema for each object:
    {
      "name": "Station Name",
      "address": "Complete Address, City, State",
      "distance": <double>,
      "chargingSpeed": <int, 0 for swap stations>,
      "estimatedTime": <int, minutes>,
      "connectorTypes": ["CCS", "CHAdeMO", etc],
      "isCompatible": <bool>,
      "rating": <double, 3.5-5.0>,
      "reviews": <int>,
      "isBatterySwapping": <bool>,
      "availableBatteries": <int, 0 for charging stations>,
      "compatibleModels": ["NIO ES8", etc],
      "co2Reduction": <double>,
      "isRenewablePowered": <bool>,
      "renewableEnergyType": "Solar" | "Wind" | "Hydro" | "Mixed" | "",
      "supportsCommunity": <bool>,
      "communityBenefits": "Description of benefits",
      "latitude": <double>,
      "longitude": <double>
    }
    ''';

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent'),
      headers: {
        'Content-Type': 'application/json',
        'X-goog-api-key': _apiKey,
      },
      body: jsonEncode({
        'contents': [{'parts': [{'text': prompt}]}]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['candidates'] == null || data['candidates'].isEmpty) {
        throw Exception('API returned no candidates.');
      }
      final text = data['candidates'][0]['content']['parts'][0]['text'];

      final jsonMatch = RegExp(r'\[.*\]', dotAll: true).firstMatch(text);
      if (jsonMatch != null) {
        final jsonString = jsonMatch.group(0)!;
        final List<dynamic> stationsData = jsonDecode(jsonString);
        return stationsData
            .map((station) => ChargingStation.fromJson(station))
            .toList();
      } else {
        throw Exception('Failed to parse JSON from the API response.');
      }
    } else {
      throw Exception(
          'Failed to get recommendations. Status: ${response.statusCode}\nBody: ${response.body}');
    }
  }

  List<ChargingStation> _createMockStations() {
    bool teslaCompatible = _selectedVehicleType == 'Tesla';
    bool ccsCompatible = _selectedVehicleType != 'Nissan Leaf';
    bool chademoCompatible = _selectedVehicleType == 'Nissan Leaf' || _selectedVehicleType.contains('CHAdeMO');
    bool nioCompatible = _selectedVehicleType.contains('NIO');

    List<ChargingStation> stations = [];

    if (_selectedServiceType == 'Both' || _selectedServiceType == 'Charging Only') {
      stations.addAll([
        ChargingStation(
          name: 'Tesla Solar Supercharger',
          address: 'Green Energy Plaza, Exit 42',
          distance: 1.2,
          chargingSpeed: 250,
          estimatedTime: 15,
          connectorTypes: ['Tesla Supercharger'],
          isCompatible: teslaCompatible,
          rating: 4.8,
          reviews: 324,
          isBatterySwapping: false,
          availableBatteries: 0,
          compatibleModels: [],
          co2Reduction: 35.2,
          isRenewablePowered: true,
          renewableEnergyType: 'Solar',
          supportsCommunity: true,
          communityBenefits: 'Local job creation, educational programs',
          location: LatLng(17.3900, 78.4850), // Mock coordinates near Hyderabad
        ),
        ChargingStation(
          name: 'Electrify America WindPower',
          address: 'Sustainable Mall, 1234 Green St',
          distance: 3.8,
          chargingSpeed: 150,
          estimatedTime: 30,
          connectorTypes: ['CCS', 'CHAdeMO'],
          isCompatible: ccsCompatible || chademoCompatible,
          rating: 4.2,
          reviews: 187,
          isBatterySwapping: false,
          availableBatteries: 0,
          compatibleModels: [],
          co2Reduction: 28.7,
          isRenewablePowered: true,
          renewableEnergyType: 'Wind',
          supportsCommunity: false,
          communityBenefits: '',
          location: LatLng(17.4100, 78.4750),
        ),
      ]);
    }

    if (_selectedServiceType == 'Both' || _selectedServiceType == 'Battery Swapping Only') {
      stations.add(
        ChargingStation(
          name: 'NIO Power Swap Station',
          address: '789 Tech Park Way',
          distance: 3.0,
          chargingSpeed: 0,
          estimatedTime: 5,
          connectorTypes: [],
          isCompatible: nioCompatible,
          rating: 4.6,
          reviews: 89,
          isBatterySwapping: true,
          availableBatteries: 12,
          compatibleModels: ['NIO ES8', 'NIO ES6'],
          co2Reduction: 20.0,
          isRenewablePowered: true,
          renewableEnergyType: 'Solar',
          supportsCommunity: true,
          communityBenefits: 'Workforce development, local partnerships',
          location: LatLng(17.4000, 78.4900),
        ),
      );
    }
    
    return stations.take(3).toList();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}

// Map View Screen for showing route with all stations
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
        point: startLocation,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'START',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.location_on, color: Colors.green, size: 30),
            ],
          ),
        ),
      ),
    );

    // Destination marker
    markers.add(
      Marker(
        point: destinationLocation,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'END',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(Icons.flag, color: Colors.red, size: 30),
            ],
          ),
        ),
      ),
    );

    // Charging station markers
    for (var station in chargingStations) {
      if (station.location != null) {
        markers.add(
          Marker(
            point: station.location!,
            child: GestureDetector(
              onTap: () => _showStationInfo(context, station),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: station.isRenewablePowered ? Colors.orange : Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        station.isBatterySwapping ? 'SWAP' : 'CHARGE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      station.isBatterySwapping ? Icons.swap_horiz : Icons.electric_bolt,
                      color: station.isRenewablePowered ? Colors.orange : Colors.blue,
                      size: 25,
                    ),
                  ],
                ),
              ),
            ),),
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
                    Text(
                      '${station.renewableEnergyType} powered - ${station.co2Reduction} kg CO₂ saved',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),),
    );
  }
}

// Single Station Map View
class SingleStationMapView extends StatelessWidget {
  final ChargingStation station;
  final LatLng? startLocation;
  final LatLng? destinationLocation;

  const SingleStationMapView({
    Key? key,
    required this.station,
    this.startLocation,
    this.destinationLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(station.name),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          center: station.location!,
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ev_charging_app',
          ),
          MarkerLayer(
            markers: _buildMarkers(),
          ),
          if (startLocation != null && destinationLocation != null)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [startLocation!, station.location!, destinationLocation!],
                  color: Colors.blue,
                  strokeWidth: 3.0,
                  isDotted: true,
                ),
              ],
            ),
        ],
      ),
      bottomSheet: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
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
                if (station.isRenewablePowered)
                  Icon(Icons.eco, color: Colors.green),
              ],
            ),
            SizedBox(height: 8),
            Text(station.address, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Icon(Icons.location_on, color: Colors.blue),
                    Text('${station.distance} km'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.star, color: Colors.orange),
                    Text('${station.rating}/5.0'),
                  ],
                ),
                if (station.isBatterySwapping)
                  Column(
                    children: [
                      Icon(Icons.battery_full, color: Colors.green),
                      Text('${station.availableBatteries} batteries'),
                    ],
                  )
                else
                  Column(
                    children: [
                      Icon(Icons.electric_bolt, color: Colors.green),
                      Text('${station.chargingSpeed} kW'),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),),
    );
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Station marker
    markers.add(
      Marker(
        point: station.location!,
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: station.isRenewablePowered ? Colors.orange : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  station.isBatterySwapping ? 'SWAP' : 'CHARGE',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Icon(
                station.isBatterySwapping ? Icons.swap_horiz : Icons.electric_bolt,
                color: station.isRenewablePowered ? Colors.orange : Colors.blue,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );

    // Add start and destination markers if available
    if (startLocation != null) {
      markers.add(
        Marker(
          point: startLocation!,
          child: Icon(Icons.location_on, color: Colors.green, size: 25),
        ),
      );
    }

    if (destinationLocation != null) {
      markers.add(
        Marker(
          point: destinationLocation!,
          child: Icon(Icons.flag, color: Colors.red, size: 25),
        ),
      );
    }

    return markers;
  }
}

// Animated gradient background widget.
class AnimatedGradientBackground extends StatefulWidget {
  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 8))
          ..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.lerp(Colors.green[700], Colors.blue[400], _animation.value)!,
                Color.lerp(Colors.orange[200], Colors.green[100], 1 - _animation.value)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

// Placeholder for animated widgets if the file doesn't exist.
class AnimatedCard extends StatelessWidget {
  final Widget child;
  const AnimatedCard({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) => child;
}

class AnimatedSearchButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const AnimatedSearchButton(
      {Key? key, required this.isLoading, required this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontSize: 18),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text('Find Charging Stations'),
      );//elevartion
}