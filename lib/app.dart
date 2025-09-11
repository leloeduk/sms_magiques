import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/models/category_list.dart';
import 'data/repository/message_repository.dart';
import 'presentation/bloc/ads/ads_bloc.dart';
import 'presentation/bloc/ads/ads_event.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/bloc/category/category_event.dart';
import 'presentation/bloc/favorite/favorite_bloc.dart';
import 'presentation/bloc/favorite/favorite_event.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/widgets/update_dialog.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://github.com/leloeduk',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AdBloc>(
          create: (_) => AdBloc(dio: Dio())..add(InitializeAds()),
        ),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()..add(LoadTheme())),
        BlocProvider<FavoriteBloc>(
          create: (_) => FavoriteBloc()..add(LoadFavorites()),
        ),
        BlocProvider<CategoryBloc>(
          create: (_) =>
              CategoryBloc(MessageRepository())
                ..add(LoadAllMessages(categories)),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          ThemeData theme = ThemeData.dark();
          if (state is ThemeLoaded) {
            theme = state.themeData;
          }
          return MaterialApp(
            title: 'Paroles Magiques',
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: UpdateWrapper(child: const SplashScreen()),
          );
        },
      ),
    );
  }
}
