// category_event.dart
import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategoryMessages extends CategoryEvent {
  final String category;
  LoadCategoryMessages(this.category);

  @override
  List<Object?> get props => [category];
}

class LoadAllMessages extends CategoryEvent {
  final List<String> categories;
  LoadAllMessages(this.categories);

  @override
  List<Object?> get props => [categories];
}
