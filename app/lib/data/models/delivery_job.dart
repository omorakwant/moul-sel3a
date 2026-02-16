import 'package:equatable/equatable.dart';

/// Delivery job model — maps to `public.delivery_jobs`.
///
/// From PROJECT_CONTEXT.md:
///   - Created when an order is marked 'ready_for_pickup'
///   - Can be "Delivery Only" or "COD (Cash Collection)"
///   - Open jobs are visible to freelance drivers for bidding
class DeliveryJob extends Equatable {
  final String id;
  final String orderId;
  final String supplierId;
  final String? assignedDriverId;
  final String pickupCity;
  final String? pickupAddress;
  final String? pickupLocationName; // descriptive supplier location
  final String dropoffCity;
  final String? dropoffAddress;
  final String? dropoffLocationName; // descriptive retailer location
  final double? estimatedWeightKg;
  final String jobType; // 'delivery_only' | 'cod'
  final double? codAmount; // amount to collect if COD
  final String? deliveryPin; // 4-digit handshake PIN
  final String status; // 'open' | 'bidding_closed' | 'assigned' | 'in_transit' | 'completed' | 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  // ── Joined fields ──
  final String? supplierName;
  final String? driverName;
  final int? bidCount;

  const DeliveryJob({
    required this.id,
    required this.orderId,
    required this.supplierId,
    this.assignedDriverId,
    required this.pickupCity,
    this.pickupAddress,
    this.pickupLocationName,
    required this.dropoffCity,
    this.dropoffAddress,
    this.dropoffLocationName,
    this.estimatedWeightKg,
    required this.jobType,
    this.codAmount,
    this.deliveryPin,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.supplierName,
    this.driverName,
    this.bidCount,
  });

  /// Whether this job involves cash collection.
  bool get isCOD => jobType == 'cod';

  /// Whether this job is open for bidding.
  bool get isOpen => status == 'open';

  /// Route display string: "Casablanca → Marrakech"
  String get routeDisplay => '$pickupCity → $dropoffCity';

  /// Full pickup label: "Derb Omar, n°42 · Casablanca"
  String get pickupLabel {
    if (pickupLocationName != null && pickupLocationName!.isNotEmpty) {
      return '$pickupLocationName · $pickupCity';
    }
    return pickupAddress != null ? '$pickupAddress · $pickupCity' : pickupCity;
  }

  /// Full dropoff label: "Boutique Hay Riad · Rabat"
  String get dropoffLabel {
    if (dropoffLocationName != null && dropoffLocationName!.isNotEmpty) {
      return '$dropoffLocationName · $dropoffCity';
    }
    return dropoffAddress != null ? '$dropoffAddress · $dropoffCity' : dropoffCity;
  }

  factory DeliveryJob.fromJson(Map<String, dynamic> json) {
    return DeliveryJob(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      supplierId: json['supplier_id'] as String,
      assignedDriverId: json['assigned_driver_id'] as String?,
      pickupCity: json['pickup_city'] as String,
      pickupAddress: json['pickup_address'] as String?,
      pickupLocationName: json['pickup_location_name'] as String?,
      dropoffCity: json['dropoff_city'] as String,
      dropoffAddress: json['dropoff_address'] as String?,
      dropoffLocationName: json['dropoff_location_name'] as String?,
      estimatedWeightKg: json['estimated_weight_kg'] != null
          ? (json['estimated_weight_kg'] as num).toDouble()
          : null,
      jobType: json['job_type'] as String,
      codAmount: json['cod_amount'] != null
          ? (json['cod_amount'] as num).toDouble()
          : null,
      deliveryPin: json['delivery_pin'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      supplierName:
          (json['supplier'] as Map<String, dynamic>?)?['shop_name'] as String?,
      driverName:
          (json['driver'] as Map<String, dynamic>?)?['shop_name'] as String?,
      bidCount: json['bid_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'supplier_id': supplierId,
      if (assignedDriverId != null) 'assigned_driver_id': assignedDriverId,
      'pickup_city': pickupCity,
      'pickup_address': pickupAddress,
      'pickup_location_name': pickupLocationName,
      'dropoff_city': dropoffCity,
      'dropoff_address': dropoffAddress,
      'dropoff_location_name': dropoffLocationName,
      'estimated_weight_kg': estimatedWeightKg,
      'job_type': jobType,
      if (codAmount != null) 'cod_amount': codAmount,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, orderId, status, jobType];
}
