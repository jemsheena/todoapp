import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Import your collections when created
// import '../../features/feed/data/models/feed_item_collection.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [],
    directory: dir.path,
    // TODO: Add collections
    // schemas: [FeedItemCollectionSchema],
  );
});


