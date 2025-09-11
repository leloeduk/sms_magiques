import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial()) {
    // Charger le thème au démarrage
    on<LoadTheme>((event, emit) async {
      final box = await Hive.openBox('settings');
      final isDark = box.get('isDark', defaultValue: true);
      emit(ThemeLoaded(isDark ? ThemeData.dark() : ThemeData.light()));
    });

    // Toggle entre dark et light
    on<ToggleTheme>((event, emit) async {
      final box = await Hive.openBox('settings');
      final isDark = box.get('isDark', defaultValue: true);
      await box.put('isDark', !isDark);
      emit(ThemeLoaded(!isDark ? ThemeData.dark() : ThemeData.light()));
    });
  }
}
