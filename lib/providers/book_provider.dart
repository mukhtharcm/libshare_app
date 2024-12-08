import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';

class BookProvider extends ChangeNotifier {
  final AppDatabase database;
  List<BookWithCategory> _books = [];
  List<Category> _categories = [];
  String _searchQuery = '';
  
  BookProvider() : database = AppDatabase() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadCategories();
    await loadBooks();
  }

  List<BookWithCategory> get books => _searchQuery.isEmpty 
    ? _books 
    : _books.where((book) => 
        book.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  
  List<Category> get categories => _categories;
  String get searchQuery => _searchQuery;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> searchBooks(String query) async {
    _books = await database.searchBooks(query);
    notifyListeners();
  }

  Future<void> loadBooks() async {
    _books = await database.getAllBooksWithCategories();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await database.getAllCategories();
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    final category = CategoriesCompanion.insert(name: name);
    await database.insertCategory(category);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await database.deleteCategory(id);
    await loadCategories();
    await loadBooks(); // Reload books as some might have been cascade deleted
  }

  Future<void> addBook({
    required String title,
    required int categoryId,
    String? coverImagePath,
  }) async {
    final book = BooksCompanion.insert(
      title: title,
      categoryId: categoryId,
      coverImagePath: Value(coverImagePath),
    );
    await database.insertBook(book);
    await loadBooks();
  }

  Future<void> updateBook({
    required int id,
    required String title,
    required int categoryId,
    String? coverImagePath,
  }) async {
    final book = BooksCompanion(
      id: Value(id),
      title: Value(title),
      categoryId: Value(categoryId),
      coverImagePath: Value(coverImagePath),
    );
    await database.updateBook(book);
    await loadBooks();
  }

  Future<void> deleteBook(int id) async {
    await database.deleteBook(id);
    await loadBooks();
  }

  Future<List<BookWithCategory>> getBooksByCategory(int categoryId) async {
    return database.getBooksByCategory(categoryId);
  }
}
