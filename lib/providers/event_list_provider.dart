import 'package:flutter/material.dart';
import '../models/event_item.dart';

class EventListProvider with ChangeNotifier {
  final List<EventItem> _events = [
    EventItem(
      title: '아메리카노 1+1',
      description: '아메리카노 구매 시 한 잔 더!',
      brandName: 'Cafe Bean',
      category: '카페',
      startDate: DateTime(2025, 10, 26),
      endDate: DateTime(2025, 10, 31),
      locationLat: 36.7583,
      locationLng: 127.0006,
      placeName: '순천향대학교 카페빈',
      createdAt: DateTime(2025, 10, 26, 10, 0),
    ),
    EventItem(
      title: '햄버거 세트 20% 할인',
      description: '모든 햄버거 세트 메뉴 20% 할인',
      brandName: 'Burger King',
      category: '패스트푸드',
      startDate: DateTime(2025, 10, 27),
      endDate: DateTime(2025, 10, 30),
      locationLat: 36.7562,
      locationLng: 127.0031,
      placeName: '순천향대학교 버거킹',
      createdAt: DateTime(2025, 10, 27, 11, 0),
    ),
  ];

  String _query = '';
  String _sortType = 'latest';

  List<EventItem> get events => _events;
  String get query => _query;
  String get sortType => _sortType;

  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  void updateSortType(String newSortType) {
    _sortType = newSortType;
    notifyListeners();
  }

  void addEvent(EventItem newEvent) {
    _events.insert(0, newEvent);
    notifyListeners();
  }
}
