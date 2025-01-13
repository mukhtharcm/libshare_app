part of 'book_list_bloc.dart';

abstract class BookListEvent extends Equatable {
  const BookListEvent();

  @override
  List<Object> get props => [];
}

class LoadBooks extends BookListEvent {}

class AddBook extends BookListEvent {
  final BookWithCategory book;
  const AddBook({required this.book});

  @override
  List<Object> get props => [book];
}

class UpdateBook extends BookListEvent {
  final BookWithCategory book;
  const UpdateBook({required this.book});

  @override
  List<Object> get props => [book];
}

class DeleteBook extends BookListEvent {
  final BookWithCategory book;
  const DeleteBook({required this.book});

  @override
  List<Object> get props => [book];
}

class SearchBooks extends BookListEvent {
  final String query;
  const SearchBooks({required this.query});

  @override
  List<Object> get props => [query];
}
