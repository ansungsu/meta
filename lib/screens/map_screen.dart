import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_item.dart';
import 'event_detail_screen.dart';

class MapScreen extends StatefulWidget {
  final List<EventItem> events; // 전체 이벤트 목록
  final double nearbyKm; // 주변 반경 (필터 옵션)
  const MapScreen({super.key, required this.events, this.nearbyKm = 3});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng? _myPos; // 현재 위치
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final allowed = await _ensurePermission();
    if (!allowed) {
      // 권한 거부 시: 순천향대 근처 기본 좌표
      _myPos = const LatLng(36.7690, 126.9315);
      _buildMarkers();
      setState(() {});
      _fitToMarkers();
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _myPos = LatLng(pos.latitude, pos.longitude);

    _buildMarkers();
    setState(() {});
    _fitToMarkers();
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // 하버사인 거리(km)
  double _distanceKm(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _deg2rad(b.latitude - a.latitude);
    final dLon = _deg2rad(b.longitude - a.longitude);
    final la1 = _deg2rad(a.latitude);
    final la2 = _deg2rad(b.latitude);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(la1) * math.cos(la2) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
    return R * c;
  }

  double _deg2rad(double d) => d * math.pi / 180.0;

  void _buildMarkers() {
    // 1) 좌표가 있는 이벤트만 대상
    final withCoords = widget.events.where(
      (e) => e.locationLat != null && e.locationLng != null,
    );

    // 2) 내 위치가 있으면 반경 필터 적용, 없거나 결과가 없으면 전체 사용
    Iterable<EventItem> target = withCoords;
    if (_myPos != null) {
      final filtered = withCoords.where(
        (e) =>
            _distanceKm(_myPos!, LatLng(e.locationLat!, e.locationLng!)) <=
            widget.nearbyKm,
      );
      target = filtered.isNotEmpty ? filtered : withCoords; // 🔁 fallback: 전체
    }

    final mks = <Marker>{};

    // (선택) 내 위치 마커
    if (_myPos != null) {
      mks.add(
        Marker(
          markerId: const MarkerId('me'),
          position: _myPos!,
          infoWindow: const InfoWindow(title: '내 위치'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    // 이벤트 마커 전부 추가
    for (final e in target) {
      final p = LatLng(e.locationLat!, e.locationLng!);
      mks.add(
        Marker(
          markerId: MarkerId('event_${e.title}_${p.latitude}_${p.longitude}'),
          position: p,
          infoWindow: InfoWindow(
            title: e.brandName,
            snippet: e.title,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
              );
            },
          ),
          onTap: () => _openBottomSheet(e),
        ),
      );
    }

    _markers = mks;
  }

  // 현재 마커들 범위에 맞춰 카메라 이동
  void _fitToMarkers() {
    if (_mapController == null || _markers.isEmpty) return;

    double minLat = _markers.first.position.latitude;
    double maxLat = _markers.first.position.latitude;
    double minLng = _markers.first.position.longitude;
    double maxLng = _markers.first.position.longitude;

    for (final m in _markers) {
      final lat = m.position.latitude;
      final lng = m.position.longitude;
      minLat = math.min(minLat, lat);
      maxLat = math.max(maxLat, lat);
      minLng = math.min(minLng, lng);
      maxLng = math.max(maxLng, lng);
    }

    // 마커가 하나면 약간 확대만
    if (minLat == maxLat && minLng == maxLng) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15),
      );
    } else {
      final bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 60), // padding
      );
    }
  }

  void _openBottomSheet(EventItem e) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.brandName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(e.title),
              if (e.placeName != null && e.placeName!.isNotEmpty)
                Text(e.placeName!, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: e),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('상세 보기'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(e.locationLat!, e.locationLng!),
                          16,
                        ),
                      );
                    },
                    icon: const Icon(Icons.center_focus_strong),
                    label: const Text('중심 이동'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = _myPos ?? const LatLng(36.7690, 126.9315);
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도 보기 (내 주변 제휴 업체)'),
        actions: [
          IconButton(
            tooltip: '전체 맞춤',
            icon: const Icon(Icons.fit_screen),
            onPressed: _fitToMarkers,
          ),
          IconButton(
            tooltip: '내 위치로 이동',
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_myPos != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(_myPos!, 15),
                );
              }
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: initial, zoom: 14),
        myLocationEnabled: false, // Web에선 비활성 권장
        myLocationButtonEnabled: false,
        markers: _markers,
        onMapCreated: (c) {
          _mapController = c;
          // 맵 생성 직후에도 한 번 맞춰주기
          WidgetsBinding.instance.addPostFrameCallback((_) => _fitToMarkers());
        },
      ),
    );
  }
}
