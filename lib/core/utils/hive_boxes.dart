import 'package:hive_flutter/hive_flutter.dart';
import 'package:sms_magique/data/models/message_model.dart';

class HiveBoxes {
  static const String favoritesBox = 'favorites';
  static const String settingsBox = 'settings';

  /// Initialise Hive et enregistre les adapters
  static Future<void> initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MessageModelAdapter());
    }

    await Hive.openBox<MessageModel>(favoritesBox);
    await Hive.openBox(settingsBox);

    // Ouvrir box par catégorie
    final categories = [
      "drague",
      "pardon",
      "anniversaire",
      "condoleances",
      "merci",
      "felicitations",
      "bonjour_bonne_nuit",
      "motivation",
      "fetes",
      "amitie",
      "autres",
    ];
    for (var cat in categories) {
      if (!Hive.isBoxOpen(cat)) {
        await Hive.openBox<MessageModel>(cat);
      }
    }
  }

  static Box<MessageModel> getFavoritesBox() =>
      Hive.box<MessageModel>(favoritesBox);

  static Box<MessageModel> getCategoryBox(String category) =>
      Hive.box<MessageModel>(category);
}
