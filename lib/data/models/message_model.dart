import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String category;

  MessageModel({required this.id, required this.text, required this.category});

  // Méthode pour créer une copie détachée de l'objet
  MessageModel copyDetached() {
    return MessageModel(id: id, text: text, category: category);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          category == other.category;

  @override
  int get hashCode => id.hashCode ^ text.hashCode ^ category.hashCode;
}
