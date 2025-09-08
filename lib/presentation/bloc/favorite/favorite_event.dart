import '../../../data/models/message_model.dart';

abstract class FavoriteEvent {}

class LoadFavorites extends FavoriteEvent {}

class AddFavorite extends FavoriteEvent {
  final MessageModel message;

  AddFavorite(this.message);
}

class RemoveFavorite extends FavoriteEvent {
  final MessageModel message;

  RemoveFavorite(this.message);
}

class ClearAllFavorites extends FavoriteEvent {}
