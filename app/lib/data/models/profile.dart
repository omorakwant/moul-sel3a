import 'package:equatable/equatable.dart';

/// User profile model — maps to `public.profiles` table.
///
/// Roles: supplier | retailer | driver
class Profile extends Equatable {
  final String id; // UUID from Supabase Auth
  final String shopName;
  final String role; // 'supplier' | 'retailer' | 'driver'
  final String? phone;
  final String? city;
  final String? locationName; // descriptive location label (e.g. "Derb Omar, n°42")
  final String? avatarUrl;
  final String preferredLanguage; // 'fr' | 'ar'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.shopName,
    required this.role,
    this.phone,
    this.city,
    this.locationName,
    this.avatarUrl,
    this.preferredLanguage = 'fr',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether this profile is a Supplier (Admin).
  bool get isSupplier => role == 'supplier';

  /// Whether this profile is a Retailer (Buyer/Moul Hanout).
  bool get isRetailer => role == 'retailer';

  /// Whether this profile is a Driver (Livreur/Kourtia).
  bool get isDriver => role == 'driver';

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      shopName: json['shop_name'] as String,
      role: json['role'] as String,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      locationName: json['location_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'fr',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'role': role,
      'phone': phone,
      'city': city,
      'location_name': locationName,
      'avatar_url': avatarUrl,
      'preferred_language': preferredLanguage,
      // created_at and updated_at handled by DB
    };
  }

  Profile copyWith({
    String? shopName,
    String? phone,
    String? city,
    String? locationName,
    String? avatarUrl,
    String? preferredLanguage,
  }) {
    return Profile(
      id: id,
      shopName: shopName ?? this.shopName,
      role: role,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      locationName: locationName ?? this.locationName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, shopName, role, phone, city, locationName, avatarUrl, preferredLanguage];
}
