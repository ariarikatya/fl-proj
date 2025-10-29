class Master {
  final String id;
  final String name;
  final String specialization;
  final String photoUrl;
  final double rating;
  final int experienceYears;
  final int reviewsCount;

  const Master({
    required this.id,
    required this.name,
    required this.specialization,
    required this.photoUrl,
    required this.rating,
    required this.experienceYears,
    required this.reviewsCount,
  });

  // Factory method to create from backend JSON
  factory Master.fromJson(Map<String, dynamic> json) {
    return Master(
      id: json['id'] as String,
      name: json['name'] as String,
      specialization: json['specialization'] as String,
      photoUrl: json['photo_url'] as String,
      rating: (json['rating'] as num).toDouble(),
      experienceYears: json['experience_years'] as int,
      reviewsCount: json['reviews_count'] as int,
    );
  }
}
