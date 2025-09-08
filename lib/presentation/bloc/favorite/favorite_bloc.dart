import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../../core/utils/hive_boxes.dart';
import '../../../data/models/message_model.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc() : super(FavoriteInitial()) {
    on<LoadFavorites>((event, emit) async {
      try {
        final box = Hive.box<MessageModel>(HiveBoxes.favoritesBox);
        emit(FavoriteLoaded(List<MessageModel>.from(box.values)));
      } catch (e) {
        emit(FavoriteError('Erreur lors du chargement des favoris: $e'));
      }
    });

    on<AddFavorite>((event, emit) async {
      try {
        final box = Hive.box<MessageModel>(HiveBoxes.favoritesBox);

        // Utiliser une copie détachée pour éviter l'erreur Hive
        final detachedMessage = event.message.copyDetached();

        if (!box.containsKey(detachedMessage.id)) {
          await box.put(detachedMessage.id, detachedMessage);
        }

        emit(FavoriteLoaded(List<MessageModel>.from(box.values)));
      } catch (e) {
        emit(FavoriteError('Erreur lors de l\'ajout aux favoris: $e'));
      }
    });

    on<RemoveFavorite>((event, emit) async {
      try {
        final box = Hive.box<MessageModel>(HiveBoxes.favoritesBox);
        await box.delete(event.message.id);
        emit(FavoriteLoaded(List<MessageModel>.from(box.values)));
      } catch (e) {
        emit(FavoriteError('Erreur lors de la suppression des favoris: $e'));
      }
    });

    on<ClearAllFavorites>((event, emit) async {
      try {
        final box = Hive.box<MessageModel>(HiveBoxes.favoritesBox);
        await box.clear();
        emit(FavoriteLoaded(List<MessageModel>.from(box.values)));
      } catch (e) {
        emit(FavoriteError('Erreur lors de la suppression des favoris: $e'));
      }
    });

    // Charger les favoris au démarrage
    add(LoadFavorites());
  }
}
