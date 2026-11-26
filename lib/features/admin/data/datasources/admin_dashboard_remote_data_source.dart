import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/admin_dashboard_stats_model.dart';
import 'admin_dashboard_data_source.dart';

class AdminDashboardRemoteDataSource implements AdminDashboardDataSource {
  const AdminDashboardRemoteDataSource(this._firestore);

  static const _upcomingStatuses = [
    'confirmed',
    'pending',
    'scheduled',
    'booked',
  ];

  final FirebaseFirestore _firestore;

  @override
  Future<AdminDashboardStatsModel> getDashboardStats() async {
    final users = _firestore.collection('users');
    final doctors = _firestore.collection('doctors');
    final specialties = _firestore.collection('specialties');
    final appointments = _firestore.collection('appointments');
    final now = Timestamp.fromDate(DateTime.now());

    final counts = await Future.wait<int?>([
      _count(users.where('role', isEqualTo: 'patient'), 'total patients'),
      _count(doctors, 'total doctors'),
      _count(
        doctors.where('approvalStatus', isEqualTo: 'pending'),
        'pending doctors',
      ),
      _count(
        doctors.where('approvalStatus', isEqualTo: 'approved'),
        'approved doctors',
      ),
      _count(specialties, 'total specialties'),
      _count(appointments, 'total appointments'),
      _count(
        appointments
            .where('status', whereIn: _upcomingStatuses)
            .where('appointmentAt', isGreaterThan: now),
        'upcoming appointments',
      ),
      _count(
        appointments.where('status', isEqualTo: 'completed'),
        'completed appointments',
      ),
    ]);

    return AdminDashboardStatsModel.fromCounts(counts);
  }

  Future<int?> _count(
    Query<Map<String, dynamic>> query,
    String metricName,
  ) async {
    try {
      return (await query.count().get()).count;
    } on FirebaseException catch (error) {
      debugPrint(
        'Admin dashboard metric unavailable: $metricName (${error.code})',
      );
      return null;
    }
  }
}
