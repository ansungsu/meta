import 'package:flutter/material.dart';
import '../models/event_item.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'add_event_screen.dart';
import 'map_screen.dart';

enum SortType { latest, endingSoon }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<EventItem> events = [
    EventItem(
      title: '카페 XYZ 할인 이벤트',
      description: '학생증 제시 시 전 메뉴 30% 할인!',
      brandName: '카페 XYZ',
      category: '카페',
      startDate: DateTime(2025, 8, 1),
      endDate: DateTime(2025, 8, 31),

      // 위치 필드는 선택
      // locationLat: 36.7697, locationLng: 126.9320, placeName: '순천향대 정문 앞 카페 XYZ',
      createdAt: DateTime(2025, 8, 10, 10, 30), // ✅ 게시물 등록시간
    ),
    EventItem(
      title: '치킨나라 사이드 증정',
      description: '대학생 인증 시 사이드메뉴 무료!',
      brandName: '치킨나라',
      category: '음식점',
      startDate: DateTime(2025, 8, 5),
      endDate: DateTime(2025, 8, 25),

      // locationLat: 36.7709, locationLng: 126.9350, placeName: '치킨나라 순천향대점',
      createdAt: DateTime(2025, 8, 11, 9, 15), // ✅ 최신
    ),
    EventItem(
      title: '서점 할인 행사',
      description: '교재 구매 시 10% 할인',
      brandName: '대학서점',
      category: '문구/서점',
      startDate: DateTime(2025, 8, 3),
      endDate: DateTime(2025, 8, 30),

      // locationLat: 36.7689, locationLng: 126.9312, placeName: '대학서점',
      createdAt: DateTime(2025, 8, 8, 17, 00),
    ),
  ];

  // 🔍 검색 상태
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // 🔽 정렬 상태
  SortType _sortType = SortType.latest;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _addEvent(EventItem newEvent) {
    setState(() {
      events.add(newEvent);
    });
  }

  void _openAddScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEventScreen(onAdd: _addEvent)),
    );
  }

  void _openMapScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapScreen(events: events)),
    );
  }

  // 필터 + 정렬
  List<EventItem> get _processedList {
    // 1) 검색
    final q = _query.trim().toLowerCase();
    List<EventItem> filtered = q.isEmpty
        ? List<EventItem>.from(events)
        : events.where((e) {
            return e.brandName.toLowerCase().contains(q) ||
                e.title.toLowerCase().contains(q) ||
                e.category.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q);
          }).toList();

    // 2) 정렬
    if (_sortType == SortType.latest) {
      // ✅ 최신순 = createdAt 내림차순
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortType == SortType.endingSoon) {
      // ✅ 마감순 = endDate 오름차순
      filtered.sort((a, b) => a.endDate.compareTo(b.endDate));
    }
    return filtered;
  }

  void _toggleSort() {
    setState(() {
      _sortType = _sortType == SortType.latest
          ? SortType.endingSoon
          : SortType.latest;
    });
  }

  String get sortLabel => _sortType == SortType.latest ? '최신순' : '마감순';

  @override
  Widget build(BuildContext context) {
    final list = _processedList;

    return Scaffold(
      appBar: AppBar(
        title: const Text('대학 제휴 이벤트'),
        actions: [
          IconButton(
            tooltip: '지도 보기',
            icon: const Icon(Icons.map),
            onPressed: _openMapScreen,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // 검색창
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: '업체명 / 이벤트명 / 카테고리 검색',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: '지우기',
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 정렬 버튼
                OutlinedButton.icon(
                  onPressed: _toggleSort,
                  icon: const Icon(Icons.sort),
                  label: Text(sortLabel),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: list.isEmpty
          ? const Center(child: Text('검색 결과가 없습니다.'))
          : ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final event = list[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        tooltip: '새 이벤트 등록',
        child: const Icon(Icons.add),
      ),
    );
  }
}
