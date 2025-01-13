import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libshare_app/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:drift/drift.dart';

part 'book_list_event.dart';
part 'book_list_state.dart';

class BookListBloc extends Bloc<BookListEvent, BookListState> {
  final AppDatabase database;

  BookListBloc({required this.database}) : super(BookListInitial()) {
    on<LoadBooks>(_onLoadBooks);
    on<AddBook>(_onAddBook);
    on<UpdateBook>(_onUpdateBook);
    on<DeleteBook>(_onDeleteBook);
    on<SearchBooks>(_onSearchBooks);
    on<LoadCategories>(_onLoadCategories);
  }

  void _onLoadBooks(LoadBooks event, Emitter<BookListState> emit) async {
    emit(BookListLoading());
    try {
      final books = await database.getAllBooksWithCategories();
      emit(BookListLoaded(books: books));
    } catch (e) {
      emit(BookListError(message: e.toString()));
    }
  }

  void _onAddBook(AddBook event, Emitter<BookListState> emit) async {
    if (state is BookListLoaded) {
      emit(BookListLoading());
      try {
        await database.insertBook(
          BooksCompanion(
            title: Value(event.book.title),
            categoryId: Value(event.book.categoryId),
            coverImagePath: Value(event.book.coverImagePath),
          ),
        );
        final books = await database.getAllBooksWithCategories();
        emit(BookListLoaded(books: books));
      } catch (e) {
        emit(BookListError(message: e.toString()));
      }
    }
  }

  void _onUpdateBook(UpdateBook event, Emitter<BookListState> emit) async {
    if (state is BookListLoaded) {
      emit(BookListLoading());
      try {
        await database.updateBook(
          BooksCompanion(
            id: Value(event.book.id),
            title: Value(event.book.title),
            categoryId: Value(event.book.categoryId),
            coverImagePath: Value(event.book.coverImagePath),
          ),
        );
        final books = await database.getAllBooksWithCategories();
        emit(BookListLoaded(books: books));
      } catch (e) {
        emit(BookListError(message: e.toString()));
      }
    }
  }

  void _onDeleteBook(DeleteBook event, Emitter<BookListState> emit) async {
    if (state is BookListLoaded) {
      emit(BookListLoading());
      try {
        await database.deleteBook(event.book.id);
        final books = await database.getAllBooksWithCategories();
        emit(BookListLoaded(books: books));
      } catch (e) {
        emit(BookListError(message: e.toString()));
      }
    }
  }

  void _onSearchBooks(SearchBooks event, Emitter<BookListState> emit) async {
    emit(BookListLoading());
    try {
      final books = await database.searchBooks(event.query);
      emit(BookListLoaded(books: books));
    } catch (e) {
      emit(BookListError(message: e.toString()));
    }
  }

  void _onLoadCategories(
      LoadCategories event, Emitter<BookListState> emit) async {
    emit(BookListLoading());
    try {
      final categories = await database.getAllCategories();
      emit(BookListLoaded(books: const [], categories: categories));
    } catch (e) {
      emit(BookListError(message: e.toString()));
    }
  }
}
