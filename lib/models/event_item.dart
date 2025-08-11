class EventItem {
  final String title;
  final String description;
  final String brandName;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final double? locationLat;
  final double? locationLng;
  final String? placeName;

  // 📌 게시물 등록 시간
  final DateTime createdAt;

  EventItem({
    required this.title,
    required this.description,
    required this.brandName,
    required this.category,
    required this.startDate,
    required this.endDate,
    this.locationLat,
    this.locationLng,
    this.placeName,
    DateTime? createdAt, // 전달 안 하면 자동으로 현재 시간
  }) : createdAt = createdAt ?? DateTime.now();
}
