import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libshare_app/database/database.dart';
import 'package:equatable/equatable.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final AppDatabase database;

  CategoryBloc({required this.database}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
  }

  void _onLoadCategories(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await database.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }

  void _onAddCategory(AddCategory event, Emitter<CategoryState> emit) async {
    debugPrint('Adding Category');
    try {
      await database.insertCategory(
        CategoriesCompanion(
          name: event.category.name,
        ),
      );
      final categories = await database.getAllCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      debugPrint("an error Occured");
      debugPrint(e.toString());
      emit(CategoryError(message: e.toString()));
    }
  }
}

class AddCategory extends CategoryEvent {
  final CategoriesCompanion category;
  const AddCategory({required this.category});
  @override
  List<Object> get props => [category];
}
