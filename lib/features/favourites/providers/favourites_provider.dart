import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/resource_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../../resource/providers/resource_provider.dart';

class FavouritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences prefs;
  static const String _favKey = 'user_favourite_item_ids';

  FavouritesNotifier({required this.prefs}) : super({}) {
    _loadFavourites();
  }

  void _loadFavourites() {
    final list = prefs.getStringList(_favKey) ?? [];
    state = Set.from(list);
  }

  Future<void> toggleFavourite(String resourceId) async {
    final current = Set<String>.from(state);
    if (current.contains(resourceId)) {
      current.remove(resourceId);
    } else {
      current.add(resourceId);
    }
    state = current;
    await prefs.setStringList(_favKey, current.toList());
  }

  bool isFavourite(String resourceId) {
    return state.contains(resourceId);
  }
}

final favouritesNotifierProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>((ref) {
  return FavouritesNotifier(
    prefs: ref.watch(sharedPreferencesProvider),
  );
});

final favouriteResourcesStreamProvider = Provider<List<ResourceEntity>>((ref) {
  final favSet = ref.watch(favouritesNotifierProvider);
  final allResourcesAsync = ref.watch(allResourcesStreamProvider);

  return allResourcesAsync.when(
    data: (list) => list.where((item) => favSet.contains(item.id)).toList(),
    loading: () => [],
    error: (_, _) => [],
  );
});
