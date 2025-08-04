import 'package:flutter/material.dart';

import 'charging_station_screen.dart';

class ReviewDialog extends StatefulWidget {
  final List<ChargingStation> stations;
  final ChargingStation? preSelectedStation;

  const ReviewDialog({
    Key? key, 
    required this.stations,
    this.preSelectedStation,
  }) : super(key: key);

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  late String selectedStation;
  double currentRating = 5.0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedStation = widget.preSelectedStation?.name ?? widget.stations.first.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Review'),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Station selector with overflow handling
              DropdownButtonFormField<String>(
                value: selectedStation,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Select Station',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: widget.stations.map((station) {
                  return DropdownMenuItem<String>(
                    value: station.name,
                    child: Text(
                      station.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedStation = newValue;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              // Rating section
              Text(
                'Rating: ${currentRating.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Slider(
                value: currentRating,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                label: currentRating.toStringAsFixed(1),
                onChanged: (double value) {
                  setState(() {
                    currentRating = value;
                  });
                },
              ),
              SizedBox(height: 20),
              // Review text field
              TextField(
                controller: _reviewController,
                decoration: InputDecoration(
                  labelText: 'Your Review',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  hintText: 'Write your experience...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Here you would typically send the review to your backend
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Review submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
          ),
          child: Text('Submit Review'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
}
