import 'package:isar/isar.dart';

part 'category.g.dart';
//! Note: dart run build_runner build <run this cmd after init model> 

@Collection()
class Category {
  Id id = Isar.autoIncrement;
  late String title;
  late bool isDefault;
}