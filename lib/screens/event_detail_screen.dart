import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/event_item.dart';

class EventDetailScreen extends StatelessWidget {
  final EventItem event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: Text(event.brandName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${event.brandName} • ${df.format(event.startDate)} ~ ${df.format(event.endDate)}',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const Divider(height: 32),
            Text(event.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),

            if (event.locationLat != null && event.locationLng != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📍 위치 보기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 300,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(event.locationLat!, event.locationLng!),
                        zoom: 15,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('event'),
                          position: LatLng(
                            event.locationLat!,
                            event.locationLng!,
                          ),
                          infoWindow: InfoWindow(
                            title: event.brandName,
                            snippet: event.placeName ?? '',
                          ),
                        ),
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
