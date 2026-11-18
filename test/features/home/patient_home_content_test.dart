import 'package:book_ease/features/home/domain/entities/patient_home_data.dart';
import 'package:book_ease/features/home/domain/entities/home_section_data.dart';
import 'package:book_ease/features/home/domain/entities/patient_profile.dart';
import 'package:book_ease/features/home/presentation/widgets/patient_home_content.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('patient home shows profile and supports clearing search', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    var query = '';
    final data = PatientHomeData(
      profile: const PatientProfile(
        fullName: '',
        imageUrl: '',
        role: 'patient',
      ),
      specialties: const HomeSectionData(value: []),
      featuredDoctors: const HomeSectionData(value: []),
      upcomingAppointment: const HomeSectionData(value: null),
    );

    await tester.pumpWidget(
      ScreenUtilPlusInit(
        designSize: const Size(360, 690),
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PatientHomeContent(
                data: data,
                searchController: controller,
                searchQuery: query,
                onSearchChanged: (value) => setState(() => query = value),
                onClearSearch: () => setState(() {
                  controller.clear();
                  query = '';
                }),
                onNotificationsTap: () {},
                onSeeAll: () {},
                onBookAppointment: () {},
                onRefresh: () async {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to BookEase'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'heart');
    await tester.pump();
    expect(find.byTooltip('Clear search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
