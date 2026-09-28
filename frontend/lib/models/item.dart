class Item {
  final int id;
  final int userId;
  final String name;
  final String? description;
  final String status;
  final int bountyPoints;
  final int? resolvedBy;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;
  final double? distance; // Added for nearby distance
  final String? userName;
  final String? userPhotoUrl;

  Item({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.status,
    required this.bountyPoints,
    this.resolvedBy,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.distance,
    this.userName,
    this.userPhotoUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      bountyPoints: json['bounty_points'] ?? 0,
      resolvedBy: json['resolved_by'],
      photoUrl: json['photo_url'],
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : null,
      distance: json['distance'] != null ? double.parse(json['distance'].toString()) : null,
      userName: json['user'] != null ? json['user']['name'] : null,
      userPhotoUrl: json['user'] != null ? json['user']['photo_url'] : null,
    );
  }
}
