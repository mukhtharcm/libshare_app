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
  const BookListLoaded({required this.books});

  @override
  List<Object> get props => [books];
}

class BookListError extends BookListState {
  final String message;
  const BookListError({required this.message});

  @override
  List<Object> get props => [message];
}
