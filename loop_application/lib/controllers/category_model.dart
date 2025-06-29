import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loop_application/models/category.dart';
// import 'package:path_provider/path_provider.dart';

class CategoryModel extends ChangeNotifier {
  static late Isar isar;

  //*Init - Database
  static Future<void> initialize(Isar isarGlobal) async {
    isar = isarGlobal;
    if (await isar.categorys.get(1) == null &&
        await isar.categorys.get(2) == null) {
      final initDefaultCategory = Category();
      final initFavoriteCategory = Category();
      initDefaultCategory.isDefault = true;
      initDefaultCategory.title = "Tất cả";
      initFavoriteCategory.isDefault = true;
      initFavoriteCategory.title = "★";
      await isar.writeTxn(() => isar.categorys.put(initFavoriteCategory));
      await isar.writeTxn(() => isar.categorys.put(initDefaultCategory));
    }
  }

  //* List of categories
  final List<Category> currentCategory = [];
  // final List<Category> allCategory = [];
  final List<Category> selectedCategory = [];

  //* CREATE a category and save to db
  Future<void> createCategory(String categoryTitle) async {
    final newCategory = Category();
    newCategory.isDefault = false;
    newCategory.title = categoryTitle;
    await isar.writeTxn(() => isar.categorys.put(newCategory));
    await fetchCategories();
  }

  //* READ categories from db
  Future<void> fetchCategories() async {
    List<Category> fetchedCategories = await isar.categorys.where().findAll();
    currentCategory.clear();
    currentCategory.addAll(fetchedCategories);
    notifyListeners();
  }

  //* READ categories from db
  Future<void> fetchSelectedCategory(int categoryId) async {
    List<Category> fetchedCategories = await isar.categorys.filter().idEqualTo(categoryId).findAll();
    selectedCategory.clear();
    selectedCategory.addAll(fetchedCategories);
    notifyListeners();
  }



  //* UPDATE a category in db
  Future<void> updateCategory(int id, String newTitle) async {
    final existingCategory = await isar.categorys.get(id);
    if (existingCategory != null) {
      existingCategory.title = newTitle;
      await isar.writeTxn(() => isar.categorys.put(existingCategory));
      await fetchCategories();
    }
  }

  //* DELETE a category from db
  Future<void> deleteCategory(int id) async {
    await isar.writeTxn(() => isar.categorys.delete(id));
    await fetchCategories();
  }

  //! CLEAR WHOLE CATEGORY DB, FOR DEV PURPOSES ONLY
  Future<void> deleteAllCategory() async {
    await isar.writeTxn(() => isar.categorys.clear());
    await fetchCategories();
  }
}
