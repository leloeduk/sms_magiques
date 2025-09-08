import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme/theme_bloc.dart' show ThemeBloc;
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                bool isDark = false;
                if (state is ThemeLoaded) {
                  isDark = state.themeData.brightness == Brightness.dark;
                }
                return SwitchListTile(
                  title: const Text('Mode sombre'),
                  value: isDark,
                  onChanged: (_) {
                    BlocProvider.of<ThemeBloc>(context).add(ToggleTheme());
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            const Text('Paroles Magiques v1.0'),
          ],
        ),
      ),
    );
  }
}
