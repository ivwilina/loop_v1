import 'package:path_provider/path_provider.dart';

class LocalStoragePath {
  late final String dir;

  Future<void> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    dir = directory.path;
  }

  
}