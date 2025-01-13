import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/book_list_bloc.dart';
import '../blocs/category_bloc.dart';
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
        context.read<BookListBloc>().add(LoadBooks());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('LibShare'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _toggleSearch(context),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'All Books'),
              Tab(text: 'Categories'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_isSearching)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search books...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<BookListBloc>().add(LoadBooks());
                      },
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      context
                          .read<BookListBloc>()
                          .add(SearchBooks(query: query));
                    } else {
                      context.read<BookListBloc>().add(LoadBooks());
                    }
                  },
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  BlocBuilder<BookListBloc, BookListState>(
                    builder: (context, state) {
                      if (state is BookListLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is BookListError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is BookListLoaded) {
                        final books = state.books;
                        if (books.isEmpty) {
                          return const Center(
                            child: Text(
                              'No books added yet',
                            ),
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: books.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final book = books[index];
                            return ListTile(
                              leading: book.coverImagePath != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(book.coverImagePath!),
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.book,
                                        size: 30,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                              title: Text(
                                book.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Text(
                                book.categoryName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditBookScreen(book: book),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CategoryError) {
                        return Center(child: Text(state.message));
                      }
                      if (state is CategoryLoaded) {
                        final categories = state.categories;
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: categories.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            // final booksInCategory = bookProvider.books
                            //     .where((book) => book.categoryId == category.id)
                            //     .length;

                            return ListTile(
                              // contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  child: Icon(
                                    Icons.label,
                                    size: 24,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              title: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              // trailing: Container(
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 12,
                              //     vertical: 6,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     color: Theme.of(context)
                              //         .colorScheme
                              //         .primary
                              //         .withOpacity(0.2),
                              //     borderRadius: BorderRadius.circular(20),
                              //   ),
                              //   child: Text(
                              //     '${category.id} books',
                              //     style: TextStyle(
                              //       color: Theme.of(context).colorScheme.primary,
                              //       fontWeight: FontWeight.bold,
                              //     ),
                              //   ),
                              // ),

                              onTap: () {
                                // Future implementation
                              },
                            );
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
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
