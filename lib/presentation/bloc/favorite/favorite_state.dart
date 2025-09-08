import 'package:equatable/equatable.dart';
import 'package:sms_magique/data/models/message_model.dart';

abstract class FavoriteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<MessageModel> favorites;
  FavoriteLoaded(this.favorites);
  @override
  List<Object?> get props => [favorites];
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError([this.message = 'Une erreur est survenue']);
  @override
  List<Object?> get props => [message];
}

class FavoriteLoading extends FavoriteState {}
