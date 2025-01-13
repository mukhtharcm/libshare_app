import 'dart:io';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../blocs/book_list_bloc.dart';
import '../blocs/category_bloc.dart' as category_bloc;
import '../database/database.dart';

class AddEditBookScreen extends StatefulWidget {
  final BookWithCategory? book;

  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  int? _selectedCategoryId;
  String? _coverImagePath;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      _titleController.text = widget.book!.title;
      _selectedCategoryId = widget.book!.categoryId;
      _coverImagePath = widget.book!.coverImagePath;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _coverImagePath = image.path;
      });
    }
  }

  void _showCategoryDialog(BuildContext context) {
    final suggestedCategories = [
      {'name': 'Fiction', 'icon': Icons.book},
      {'name': 'Non-Fiction', 'icon': Icons.menu_book},
      {'name': 'Science', 'icon': Icons.science},
      {'name': 'Technology', 'icon': Icons.computer},
      {'name': 'Biography', 'icon': Icons.person},
      {'name': 'History', 'icon': Icons.account_balance},
      {'name': 'Self-Help', 'icon': Icons.psychology},
      {'name': 'Art & Design', 'icon': Icons.palette},
      {'name': 'Cooking', 'icon': Icons.restaurant},
      {'name': 'Travel', 'icon': Icons.travel_explore},
    ];

    final customCategoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => AnimatedPadding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        duration: const Duration(milliseconds: 100),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add New Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: customCategoryController,
                decoration: InputDecoration(
                  labelText: 'Custom Category Name',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Or choose a suggested category:',
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: suggestedCategories.length,
                itemBuilder: (context, index) {
                  final category = suggestedCategories[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<category_bloc.CategoryBloc>().add(
                            category_bloc.AddCategory(
                              category: CategoriesCompanion(
                                // id: 0,
                                name: Value(category['name'] as String),
                              ),
                            ),
                          );
                      if (mounted) Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            size: 30,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category['name'] as String,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          context.read<category_bloc.CategoryBloc>().add(
                                category_bloc.AddCategory(
                                  category: CategoriesCompanion(
                                    // id: 0,
                                    name: Value(
                                      customCategoryController.text.trim(),
                                    ),
                                  ),
                                ),
                              );
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Category'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final scrollPercentage =
                      (constraints.maxHeight - kToolbarHeight) /
                          (150.0 - kToolbarHeight);
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0.0, scrollPercentage.clamp(0.0, 1.0)],
                      ),
                    ),
                    child: FlexibleSpaceBar(
                      title: AnimatedOpacity(
                        opacity: scrollPercentage < 0.6 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          widget.book == null ? 'Add Book' : 'Edit Book',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      centerTitle: true,
                    ),
                  );
                },
              ),
            ),
          ];
        },
        body: BlocConsumer<BookListBloc, BookListState>(
          listener: (context, state) {
            if (state is BookListError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  // backgroundColor: Theme.of(context).
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _coverImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_coverImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocConsumer<category_bloc.CategoryBloc,
                      category_bloc.CategoryState>(
                    listener: (context, state) {
                      if (state is category_bloc.CategoryError) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(state.message),
                          // duration: const Duration(
                          //   milliseconds: 100,
                          // ),
                        ));
                      }
                    },
                    builder: (context, categoryState) {
                      return DropdownButtonFormField<int>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: state is BookListLoaded
                            ? [
                                ...state.categories?.map(
                                      (category) => DropdownMenuItem(
                                        value: category.id,
                                        child: Text(category.name),
                                      ),
                                    ) ??
                                    []
                              ]
                            : [],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Category'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.book == null) {
                          context.read<BookListBloc>().add(
                                AddBook(
                                  book: BookWithCategory(
                                    id: 0,
                                    title: _titleController.text,
                                    categoryId: _selectedCategoryId!,
                                    categoryName: '',
                                    coverImagePath: _coverImagePath,
                                  ),
                                ),
                              );
                        } else {
                          context.read<BookListBloc>().add(
                                UpdateBook(
                                  book: BookWithCategory(
                                    id: widget.book!.id,
                                    title: _titleController.text,
                                    categoryId: _selectedCategoryId!,
                                    categoryName: '',
                                    coverImagePath: _coverImagePath,
                                  ),
                                ),
                              );
                        }

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        Text(widget.book == null ? 'Add Book' : 'Update Book'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
