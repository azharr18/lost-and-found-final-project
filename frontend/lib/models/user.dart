class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final int rewardPoints;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.rewardPoints,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      rewardPoints: json['reward_points'] ?? 0,
      photoUrl: json['photo_url'],
    );
  }
}
