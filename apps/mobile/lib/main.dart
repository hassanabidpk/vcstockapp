import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vc_stocks_mobile/app.dart';
import 'package:vc_stocks_mobile/core/storage/local_cache_service.dart';
import 'package:vc_stocks_mobile/core/storage/preferences_service.dart';
import 'package:vc_stocks_mobile/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final cacheService = await LocalCacheService.init();

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(
          PreferencesService(prefs),
        ),
        localCacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const VCStocksApp(),
    ),
  );
}
