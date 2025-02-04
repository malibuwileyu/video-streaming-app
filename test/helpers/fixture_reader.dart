import 'dart:io';
import 'package:path/path.dart' as path;

/// Reads and returns the content of a fixture file
/// 
/// [name] should be the relative path from the fixtures directory
/// Example: fixture('mock_responses/video_metadata.json')
String fixture(String name) {
  var dir = Directory.current.path;
  if (path.basename(dir) == 'test') {
    dir = path.dirname(dir);
  }
  return File(path.join(dir, 'test', 'fixtures', name))
      .readAsStringSync();
} 