import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/hive_boxes.dart';
import '../../../data/models/category_list.dart';
import '../../../data/repository/message_repository.dart';
import 'category_event.dart';
import 'category_state.dart';
import 'package:sms_magique/data/models/message_model.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final MessageRepository repository;

  CategoryBloc(this.repository) : super(CategoryInitial()) {
    on<LoadCategoryMessages>((event, emit) async {
      emit(CategoryLoading());
      try {
        // Essayer de récupérer depuis Hive d'abord
        final box = HiveBoxes.getCategoryBox(event.category);
        final messagesFromHive = box.values.toList();

        if (messagesFromHive.isNotEmpty) {
          emit(CategoryLoaded(messagesFromHive));
        }

        // Télécharger les nouvelles données
        final messages = await repository.fetchMessages(event.category);
        emit(CategoryLoaded(messages));
      } catch (e) {
        emit(CategoryError("Erreur: $e"));
      }
    });

    on<LoadAllMessages>((event, emit) async {
      emit(CategoryLoading());
      try {
        List<MessageModel> allMessages = [];

        for (var cat in categories) {
          final box = HiveBoxes.getCategoryBox(cat);
          final messagesFromHive = box.values.toList();

          if (messagesFromHive.isNotEmpty) {
            allMessages.addAll(messagesFromHive);
          } else {
            final messages = await repository.fetchMessages(cat);
            allMessages.addAll(messages);
          }
        }

        emit(CategoryLoaded(allMessages));
      } catch (e) {
        emit(CategoryError("Erreur de chargement global: $e"));
      }
    });
  }
}
