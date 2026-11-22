import 'package:book_ease/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses the Firebase UID in the predictable profile image path', () {
    expect(
      profileImageStoragePath('firebase-uid-123'),
      'users/firebase-uid-123/profile.jpg',
    );
  });
}
