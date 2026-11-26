import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../domain/errors/admin_doctor_exception.dart';
import 'admin_doctor_actions_data_source.dart';

class AdminDoctorActionsRemoteDataSource
    implements AdminDoctorActionsDataSource {
  AdminDoctorActionsRemoteDataSource({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  @override
  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  }) async {
    try {
      final payload = <String, Object>{
        'targetDoctorUid': targetDoctorUid,
        'operationId': operationId,
      };
      if (reason != null) payload['reason'] = reason;
      await _functions.httpsCallable('${actionName}Doctor').call(payload);
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Admin doctor callable failed: ${error.code}');
      throw AdminDoctorException(error.code);
    }
  }
}
