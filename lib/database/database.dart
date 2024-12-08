import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class Books extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get coverImagePath => text().nullable()();
}

@DriftDatabase(tables: [Books, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle future schema upgrades here
        },
      );

  // Category operations
  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<Category> getCategory(int id) =>
      (select(categories)..where((c) => c.id.equals(id))).getSingle();

  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  Future<bool> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id)))
          .go()
          .then((rows) => rows > 0);

  // Book operations with category join
  Future<List<BookWithCategory>> getAllBooksWithCategories() {
    final query = select(books).join([
      innerJoin(categories, categories.id.equalsExp(books.categoryId)),
    ]);

    return query.map((row) {
      final book = row.readTable(books);
      final category = row.readTable(categories);
      return BookWithCategory(
        id: book.id,
        title: book.title,
        categoryId: book.categoryId,
        categoryName: category.name,
        coverImagePath: book.coverImagePath,
      );
    }).get();
  }

  Future<BookWithCategory> getBookWithCategory(int id) async {
    final query = select(books).join([
      innerJoin(categories, categories.id.equalsExp(books.categoryId)),
    ])
      ..where(books.id.equals(id));

    final row = await query.getSingle();
    final book = row.readTable(books);
    final category = row.readTable(categories);

    return BookWithCategory(
      id: book.id,
      title: book.title,
      categoryId: book.categoryId,
      categoryName: category.name,
      coverImagePath: book.coverImagePath,
    );
  }

  Future<List<BookWithCategory>> getBooksByCategory(int categoryId) {
    final query = select(books).join([
      innerJoin(categories, categories.id.equalsExp(books.categoryId)),
    ])
      ..where(books.categoryId.equals(categoryId));

    return query.map((row) {
      final book = row.readTable(books);
      final category = row.readTable(categories);
      return BookWithCategory(
        id: book.id,
        title: book.title,
        categoryId: book.categoryId,
        categoryName: category.name,
        coverImagePath: book.coverImagePath,
      );
    }).get();
  }

  Future<int> insertBook(BooksCompanion book) => into(books).insert(book);

  Future<bool> updateBook(BooksCompanion book) => update(books).replace(book);

  Future<int> deleteBook(int id) =>
      (delete(books)..where((b) => b.id.equals(id))).go();

  Future<List<BookWithCategory>> searchBooks(String query) {
    final searchTerm = '%${query.toLowerCase()}%';
    final searchQuery = select(books).join([
      innerJoin(categories, categories.id.equalsExp(books.categoryId)),
    ])
      ..where(books.title.lower().like(searchTerm));

    return searchQuery.map((row) {
      final book = row.readTable(books);
      final category = row.readTable(categories);
      return BookWithCategory(
        id: book.id,
        title: book.title,
        categoryId: book.categoryId,
        categoryName: category.name,
        coverImagePath: book.coverImagePath,
      );
    }).get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'books.db'));
    return NativeDatabase(file);
  });
}

// Data class for joined book and category data
class BookWithCategory {
  final int id;
  final String title;
  final int categoryId;
  final String categoryName;
  final String? coverImagePath;

  BookWithCategory({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.categoryName,
    this.coverImagePath,
  });
}
