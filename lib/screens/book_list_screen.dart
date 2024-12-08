import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'add_edit_book_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch(BuildContext context) {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).requestFocus(_searchFocusNode);
        });
      } else {
        _searchController.clear();
        context.read<BookProvider>().updateSearchQuery('');
        context.read<BookProvider>().loadBooks();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onChanged: (query) {
                    final bookProvider = context.read<BookProvider>();
                    bookProvider.updateSearchQuery(query);
                    if (query.isNotEmpty) {
                      bookProvider.searchBooks(query);
                    } else {
                      bookProvider.loadBooks();
                    }
                  },
                )
              : const Text('LibShare'),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.clear : Icons.search),
              onPressed: () => _toggleSearch(context),
            ),
          ],
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Books'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                final books = bookProvider.books;
                if (books.isEmpty) {
                  return Center(
                    child: Text(
                      bookProvider.searchQuery.isNotEmpty
                          ? 'No books found'
                          : 'No books added yet',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Dismissible(
                      key: Key(book.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        bookProvider.deleteBook(book.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${book.title} deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Implement undo functionality if needed
                              },
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: book.coverImagePath != null
                            ? Hero(
                                tag: 'book-${book.id}',
                                child: CircleAvatar(
                                  backgroundImage: FileImage(File(book.coverImagePath!)),
                                ),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.book),
                              ),
                        title: Text(book.title),
                        subtitle: Text(book.categoryName),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditBookScreen(book: book),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            Consumer<BookProvider>(
              builder: (context, bookProvider, child) {
                return ListView.builder(
                  itemCount: bookProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = bookProvider.categories[index];
                    final booksInCategory = bookProvider.books
                        .where((book) => book.categoryId == category.id)
                        .length;

                    return ListTile(
                      title: Text(category.name),
                      trailing: Text('$booksInCategory books'),
                      onTap: () {
                        // Future implementation
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditBookScreen(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
