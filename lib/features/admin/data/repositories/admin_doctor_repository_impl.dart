import '../../domain/entities/admin_doctor_details.dart';
import '../../domain/entities/admin_doctor_filter.dart';
import '../../domain/repositories/admin_doctor_repository.dart';
import '../datasources/admin_doctor_actions_data_source.dart';
import '../datasources/admin_doctor_details_data_source.dart';
import '../datasources/admin_doctor_list_data_source.dart';

class AdminDoctorRepositoryImpl implements AdminDoctorRepository {
  const AdminDoctorRepositoryImpl(
    this._listDataSource,
    this._detailsDataSource,
    this._actionsDataSource,
  );

  final AdminDoctorListDataSource _listDataSource;
  final AdminDoctorDetailsDataSource _detailsDataSource;
  final AdminDoctorActionsDataSource _actionsDataSource;

  @override
  Future<AdminDoctorPage> getDoctors({
    required AdminDoctorFilter filter,
    required String search,
    required String specialtyId,
    AdminDoctorCursor? cursor,
  }) => _listDataSource.getDoctors(
    filter: filter,
    search: search,
    specialtyId: specialtyId,
    cursor: cursor,
  );

  @override
  Future<List<AdminDoctorSpecialty>> getSpecialties() =>
      _listDataSource.getSpecialties();

  @override
  Future<AdminDoctorDetails> getDoctorDetails(String doctorId) =>
      _detailsDataSource.getDoctorDetails(doctorId);

  @override
  Future<AdminDoctorAuditPage> getAuditHistory({
    required String targetDoctorUid,
    AdminDoctorAuditCursor? cursor,
  }) => _detailsDataSource.getAuditHistory(
    targetDoctorUid: targetDoctorUid,
    cursor: cursor,
  );

  @override
  Future<void> performAction({
    required String actionName,
    required String targetDoctorUid,
    required String operationId,
    String? reason,
  }) => _actionsDataSource.performAction(
    actionName: actionName,
    targetDoctorUid: targetDoctorUid,
    operationId: operationId,
    reason: reason,
  );
}
