part of 'book_list_bloc.dart';

abstract class BookListState extends Equatable {
  const BookListState();

  @override
  List<Object> get props => [];
}

class BookListInitial extends BookListState {}

class BookListLoading extends BookListState {}

class BookListLoaded extends BookListState {
  final List<BookWithCategory> books;
  final List<Category>? categories;
  const BookListLoaded({required this.books, this.categories});

  @override
  List<Object> get props => [books, categories ?? []];
}

class BookListError extends BookListState {
  final String message;
  const BookListError({required this.message});

  @override
  List<Object> get props => [message];
}
