import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'bloc/habit_bloc.dart';
import 'bloc/habit_event.dart';
import 'bloc/notification_cubit.dart';
import 'bloc/theme_cubit.dart';
import 'data/habit_repository.dart';
import 'l10n/app_strings.dart';
import 'services/ad_helper.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'ui/splash_screen.dart';
import 'constants/app_secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdHelper.initialize();
  await NotificationService.instance.initialize();

  if (kDebugMode) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          AppSecrets.testDeviceId,
        ],
      ),
    );
  }

  final repository = HiveHabitRepository();
  await repository.init();

  runApp(MyApp(repository: repository));
}

class MyApp extends StatefulWidget {
  final HabitRepository repository;

  const MyApp({super.key, required this.repository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HabitBloc(repository: widget.repository)..add(LoadHabitsEvent()),
          ),
          BlocProvider(
            create: (context) => ThemeCubit(),
          ),
          BlocProvider(
            create: (context) => NotificationCubit(repository: widget.repository),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: AppStrings.appTitle,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}
