import 'package:equatable/equatable.dart';

/// Driver bid on a delivery job — maps to `public.delivery_bids`.
///
/// From PROJECT_CONTEXT.md:
///   - Drivers bid on open delivery_jobs
///   - Supplier accepts/rejects bids
///   - One bid per driver per job (enforced by DB constraint)
class DeliveryBid extends Equatable {
  final String id;
  final String jobId;
  final String driverId;
  final double bidAmount; // proposed delivery fee in DH
  final String? estimatedTime; // e.g. "2 heures", "30 min"
  final String? message; // optional note from driver
  final String status; // 'pending' | 'accepted' | 'rejected' | 'withdrawn'
  final DateTime createdAt;

  // ── Joined fields ──
  final String? driverName;
  final String? driverPhone;
  final String? driverCity;

  const DeliveryBid({
    required this.id,
    required this.jobId,
    required this.driverId,
    required this.bidAmount,
    this.estimatedTime,
    this.message,
    required this.status,
    required this.createdAt,
    this.driverName,
    this.driverPhone,
    this.driverCity,
  });

  /// Whether this bid is still pending review.
  bool get isPending => status == 'pending';

  /// Whether this bid was accepted.
  bool get isAccepted => status == 'accepted';

  factory DeliveryBid.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'] as Map<String, dynamic>?;

    return DeliveryBid(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      driverId: json['driver_id'] as String,
      bidAmount: (json['bid_amount'] as num).toDouble(),
      estimatedTime: json['estimated_time'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      driverName: driver?['shop_name'] as String?,
      driverPhone: driver?['phone'] as String?,
      driverCity: driver?['city'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'driver_id': driverId,
      'bid_amount': bidAmount,
      if (estimatedTime != null) 'estimated_time': estimatedTime,
      if (message != null) 'message': message,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [id, jobId, driverId, bidAmount, status];
}
