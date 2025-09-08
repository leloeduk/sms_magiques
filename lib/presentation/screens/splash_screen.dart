import 'package:flutter/material.dart';
import '../../core/utils/hive_boxes.dart';
import '../../data/models/category_list.dart';
import '../../data/repository/message_repository.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _loading = true;
  bool _error = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = '';
    });

    try {
      await HiveBoxes.initHive();

      final repo = MessageRepository();
      final List<Future> futures = [];

      for (var cat in categories) {
        futures.add(repo.fetchMessages(cat));
      }

      await Future.wait(futures, eagerError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    } catch (e) {
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', width: 150),
                const SizedBox(height: 20),
                if (_loading) const CircularProgressIndicator(),
              ],
            ),
          ),
          if (_error)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    "Erreur: $_errorMessage",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAllData,
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
