import 'package:equatable/equatable.dart';
import 'package:sms_magique/data/models/message_model.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<MessageModel> messages;
  CategoryLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
