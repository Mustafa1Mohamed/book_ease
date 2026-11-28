import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../../core/localization/generated/app_localizations.dart';
import '../../domain/entities/admin_specialty.dart';
import '../cubit/admin_specialties_cubit.dart';
import '../cubit/admin_specialties_state.dart';

class AdminSpecialtyFormPage extends StatefulWidget {
  const AdminSpecialtyFormPage({this.specialtyId, super.key});

  final String? specialtyId;

  @override
  State<AdminSpecialtyFormPage> createState() => _AdminSpecialtyFormPageState();
}

class _AdminSpecialtyFormPageState extends State<AdminSpecialtyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nameAr = TextEditingController();
  final _description = TextEditingController();
  final _descriptionAr = TextEditingController();
  String _iconName = 'medical';
  bool _isActive = true;
  bool _clearImage = false;
  bool _initialized = false;

  static const _icons = [
    'medical',
    'heart',
    'dental',
    'skin',
    'neurology',
    'pediatrics',
    'orthopedics',
  ];

  @override
  void dispose() {
    _name.dispose();
    _nameAr.dispose();
    _description.dispose();
    _descriptionAr.dispose();
    super.dispose();
  }

  void _initialize(AdminSpecialty? specialty) {
    if (_initialized) return;
    if (specialty != null) {
      _name.text = specialty.name;
      _nameAr.text = specialty.nameAr;
      _description.text = specialty.description;
      _descriptionAr.text = specialty.descriptionAr;
      _iconName = _icons.contains(specialty.iconName)
          ? specialty.iconName
          : 'medical';
      _isActive = specialty.isActive;
    }
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.specialtyId != null;
    final cubit = context.read<AdminSpecialtiesCubit>();
    final specialty = widget.specialtyId == null
        ? null
        : cubit.specialtyById(widget.specialtyId!);
    _initialize(specialty);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? l10n.adminSpecialtyEdit : l10n.adminSpecialtyCreate,
        ),
      ),
      body: specialty == null && isEditing
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  l10n.adminSpecialtiesLoadError,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : BlocBuilder<AdminSpecialtiesCubit, AdminSpecialtiesState>(
              builder: (context, state) {
                final width = MediaQuery.sizeOf(context).width > 800
                    ? 720.0
                    : double.infinity;
                return Center(
                  child: SizedBox(
                    width: width,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: EdgeInsets.all(20.w),
                        children: [
                          _textField(
                            controller: _name,
                            label: l10n.adminSpecialtyNameEnglish,
                            maxLength: 100,
                            validator: (value) => _validateName(value, l10n),
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            controller: _nameAr,
                            label: l10n.adminSpecialtyNameArabic,
                            maxLength: 100,
                            textDirection: TextDirection.rtl,
                            validator: (value) => _validateName(value, l10n),
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            controller: _description,
                            label: l10n.adminSpecialtyDescriptionEnglish,
                            maxLength: 2000,
                            minLines: 2,
                            maxLines: 5,
                            textDirection: TextDirection.ltr,
                          ),
                          SizedBox(height: 12.h),
                          _textField(
                            controller: _descriptionAr,
                            label: l10n.adminSpecialtyDescriptionArabic,
                            maxLength: 2000,
                            minLines: 2,
                            maxLines: 5,
                            textDirection: TextDirection.rtl,
                          ),
                          SizedBox(height: 12.h),
                          DropdownButtonFormField<String>(
                            initialValue: _iconName,
                            decoration: InputDecoration(
                              labelText: l10n.adminSpecialtyIcon,
                            ),
                            items: [
                              for (final icon in _icons)
                                DropdownMenuItem(
                                  value: icon,
                                  child: Text(_iconLabel(l10n, icon)),
                                ),
                            ],
                            onChanged: state.isSaving
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() => _iconName = value);
                                    }
                                  },
                          ),
                          SizedBox(height: 8.h),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _isActive,
                            onChanged: state.isSaving
                                ? null
                                : (value) => setState(() => _isActive = value),
                            title: Text(l10n.adminSpecialtyIsActive),
                          ),
                          Text(
                            l10n.adminSpecialtyImagePolicy,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (specialty?.imageUrl.isNotEmpty == true)
                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _clearImage,
                              onChanged: state.isSaving
                                  ? null
                                  : (value) => setState(
                                      () => _clearImage = value ?? false,
                                    ),
                              title: Text(l10n.adminSpecialtyClearImage),
                            ),
                          if (state.mutationError != null) ...[
                            SizedBox(height: 12.h),
                            Text(
                              _errorMessage(l10n, state.mutationError!),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          SizedBox(height: 18.h),
                          FilledButton(
                            onPressed: state.isSaving
                                ? null
                                : () => _save(context, cubit, l10n),
                            child: state.isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    isEditing
                                        ? l10n.doctorProfileSave
                                        : l10n.adminSpecialtyCreate,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required int maxLength,
    FormFieldValidator<String>? validator,
    int minLines = 1,
    int maxLines = 1,
    TextDirection? textDirection,
  }) => TextFormField(
    controller: controller,
    enabled: !context.watch<AdminSpecialtiesCubit>().state.isSaving,
    maxLength: maxLength,
    minLines: minLines,
    maxLines: maxLines,
    textDirection: textDirection,
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: maxLines > 1,
    ),
    validator: validator,
  );

  String? _validateName(String? value, AppLocalizations l10n) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.adminSpecialtyRequired;
    if (name.length > 100) return l10n.adminSpecialtyNameTooLong;
    return null;
  }

  Future<void> _save(
    BuildContext context,
    AdminSpecialtiesCubit cubit,
    AppLocalizations l10n,
  ) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final saved = await cubit.save(
      specialtyId: widget.specialtyId,
      name: _name.text,
      nameAr: _nameAr.text,
      description: _description.text,
      descriptionAr: _descriptionAr.text,
      iconName: _iconName,
      isActive: _isActive,
      clearImage: _clearImage,
    );
    if (saved && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.specialtyId == null
                ? l10n.adminSpecialtyCreateSuccess
                : l10n.adminSpecialtySaveSuccess,
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  String _errorMessage(AppLocalizations l10n, String code) => switch (code) {
    'already-exists' => l10n.adminSpecialtyDuplicateName,
    'permission-denied' => l10n.adminSpecialtiesLoadError,
    'invalid-argument' => l10n.adminSpecialtySaveError,
    _ => l10n.adminSpecialtySaveError,
  };

  String _iconLabel(AppLocalizations l10n, String value) => switch (value) {
    'heart' => l10n.adminSpecialtyIconHeart,
    'dental' => l10n.adminSpecialtyIconDental,
    'skin' => l10n.adminSpecialtyIconSkin,
    'neurology' => l10n.adminSpecialtyIconNeurology,
    'pediatrics' => l10n.adminSpecialtyIconPediatrics,
    'orthopedics' => l10n.adminSpecialtyIconOrthopedics,
    _ => l10n.adminSpecialtyIconMedical,
  };
}
