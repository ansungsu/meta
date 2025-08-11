import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/event_item.dart';

class AddEventScreen extends StatefulWidget {
  final Function(EventItem) onAdd;
  const AddEventScreen({super.key, required this.onAdd});
  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _brandController = TextEditingController();
  final _categoryController = TextEditingController();
  final _searchController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;

  LatLng? _selectedPosition;
  String _selectedPlaceName = '';
  GoogleMapController? _mapController;

  final String _apiKey =
      'AIzaSyAGfQqEx6BYYSQZgNBZSrP4LqH_RiTRbJA'; // TODO: 여기에 실제 키 입력

  void _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _searchPlace(String keyword) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(keyword)}&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final result = data['results'][0];
        final location = result['geometry']['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        final newPosition = LatLng(lat, lng);

        _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));

        setState(() {
          _selectedPosition = newPosition;
          _selectedPlaceName = result['formatted_address'] ?? keyword;
        });
      } else {
        print('검색 결과 없음');
      }
    } else {
      print('Geocoding API 오류');
    }
  }

  void _submit() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _selectedPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 항목을 입력하고 위치를 선택해주세요')));
      return;
    }

    final newEvent = EventItem(
      title: _titleController.text,
      description:
          '${_descriptionController.text}\n장소: $_selectedPlaceName\n위도: ${_selectedPosition!.latitude}, 경도: ${_selectedPosition!.longitude}',
      brandName: _brandController.text,
      category: _categoryController.text,
      startDate: _startDate!,
      endDate: _endDate!,

      // 👇👇👇 추가된 부분 (기존 기능 유지 + 위치 필드 저장)
      createdAt: DateTime.now(), // 📌 등록 시간 저장
      locationLat: _selectedPosition!.latitude,
      locationLng: _selectedPosition!.longitude,
      placeName: _selectedPlaceName.isNotEmpty
          ? _selectedPlaceName
          : _brandController.text,
      // 👆👆👆
    );

    widget.onAdd(newEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Scaffold(
      appBar: AppBar(title: const Text('이벤트 등록')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 텍스트 입력 영역
            TextField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: '업체명'),
            ),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: '이벤트 제목'),
            ),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '이벤트 설명'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: '카테고리 (직접 입력)'),
            ),
            const SizedBox(height: 12),

            /// 날짜 선택
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: Text(
                      _startDate == null
                          ? '시작일 선택'
                          : '시작일: ${dateFormat.format(_startDate!)}',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: Text(
                      _endDate == null
                          ? '종료일 선택'
                          : '종료일: ${dateFormat.format(_endDate!)}',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            /// 검색 입력창
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: '장소 검색 (예: 스타벅스 순천향대)',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchPlace(_searchController.text);
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            /// 지도 위젯
            SizedBox(
              height: 300,
              child: GoogleMap(
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(36.7690, 126.9315), // 순천향대
                  zoom: 15,
                ),
                onTap: (LatLng pos) {
                  setState(() {
                    _selectedPosition = pos;
                    _selectedPlaceName = _brandController.text;
                  });
                },
                markers: _selectedPosition != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedPosition!,
                          infoWindow: InfoWindow(title: _selectedPlaceName),
                        ),
                      }
                    : {},
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedPosition != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('선택된 장소: $_selectedPlaceName'),
                  // 위도/경도 텍스트는 출력하지 않음
                ],
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('이벤트 등록'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
