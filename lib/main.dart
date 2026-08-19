import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/habit_bloc.dart';
import 'bloc/habit_event.dart';
import 'bloc/theme_cubit.dart';
import 'data/habit_repository.dart';
import 'l10n/app_strings.dart';
import 'services/ad_helper.dart';
import 'theme/app_theme.dart';
import 'ui/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AdHelper.initialize();

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

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Trigger App Open Ad whenever user re-opens / resumes app
      AppOpenAdManager.instance.showAdIfAvailable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

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
