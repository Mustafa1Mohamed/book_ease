import 'dart:convert';

import 'package:book_ease/app.dart';
import 'package:book_ease/core/localization/local_cubit.dart';
import 'package:book_ease/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:book_ease/firebase_options.dart';
import 'package:book_ease/injection_container.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://bqswbjdgdjgcxczzbvlj.supabase.co',
    publishableKey: 'sb_publishable_Tlwi1YUUThgoGX7ZN41yHg_MWet8Cq5',
    accessToken: _getFirebaseAccessToken,
  );
  await setupDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LocaleCubit>()),
        BlocProvider(create: (_) => getIt<AuthCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<String?> _getFirebaseAccessToken() async {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  if (kDebugMode) {
    debugPrint(
      '[SupabaseAuthDiagnostic] firebase_user_exists=${firebaseUser != null}'
      '${firebaseUser == null ? '' : ' firebase_uid=${firebaseUser.uid}'}',
    );
  }
  if (firebaseUser == null) return null;

  try {
    final token = await firebaseUser.getIdToken();
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[SupabaseAuthDiagnostic] firebase_id_token_obtained=false '
          'jwt_role=unavailable token_project_matches_expected=false',
        );
      }
      return null;
    }
    final tokenDiagnostics = _readFirebaseTokenDiagnostics(
      token,
      DefaultFirebaseOptions.currentPlatform.projectId,
    );
    if (kDebugMode) {
      debugPrint(
        '[SupabaseAuthDiagnostic] firebase_id_token_obtained=true '
        'jwt_role=${tokenDiagnostics.role} '
        'token_project_matches_expected=${tokenDiagnostics.projectMatches}',
      );
    }
    return token;
  } catch (error, stackTrace) {
    if (kDebugMode) {
      debugPrint(
        '[SupabaseAuthDiagnostic] firebase_id_token_obtained=false '
        'exception_type=${error.runtimeType} '
        'firebase_error_code=${error is FirebaseAuthException ? error.code : 'unavailable'}',
      );
      debugPrintStack(
        label: '[SupabaseAuthDiagnostic] Firebase ID token retrieval failed',
        stackTrace: stackTrace,
      );
    }
    rethrow;
  }
}

({String role, bool projectMatches}) _readFirebaseTokenDiagnostics(
  String token,
  String expectedProjectId,
) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) {
      return (role: 'unreadable', projectMatches: false);
    }
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map<String, dynamic>) {
      return (role: 'unreadable', projectMatches: false);
    }

    final roleClaim = payload['role'];
    final issuer = payload['iss'];
    final audience = payload['aud'];
    final issuerMatches =
        issuer == 'https://securetoken.google.com/$expectedProjectId';
    final audienceMatches = audience == expectedProjectId;
    return (
      role: roleClaim is String && roleClaim.isNotEmpty ? roleClaim : 'missing',
      projectMatches: issuerMatches && audienceMatches,
    );
  } catch (_) {
    return (role: 'unreadable', projectMatches: false);
  }
}
