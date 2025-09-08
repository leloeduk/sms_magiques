import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/utils/hive_boxes.dart';
import '../models/message_model.dart';

class MessageRepository {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<MessageModel>> fetchMessages(String category) async {
    try {
      final url =
          'https://raw.githubusercontent.com/leloeduk/messages-data/main/$category.json';
      final response = await _dio.get(url);

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (data is List) {
        final messages = data
            .map(
              (json) => MessageModel(
                id: json['id'],
                text: json['text'],
                category: category,
              ),
            )
            .toList();

        // Stockage Hive par catégorie - sans batch
        final box = HiveBoxes.getCategoryBox(category);

        // Préparer tous les messages à stocker
        final Map<int, MessageModel> messagesToStore = {};
        for (var msg in messages) {
          messagesToStore[msg.id] = msg
              .copyDetached(); // Utiliser une copie détachée
        }

        // Stocker tous les messages en une opération
        await box.putAll(messagesToStore);

        return messages;
      } else {
        throw Exception('Format JSON inattendu pour $category');
      }
    } catch (e) {
      // En cas d'erreur, retourner les données Hive si disponibles
      final box = HiveBoxes.getCategoryBox(category);
      return box.values.toList();
    }
  }
}
