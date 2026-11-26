abstract interface class AdminDoctorActionsDataSource {
  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  });
}
