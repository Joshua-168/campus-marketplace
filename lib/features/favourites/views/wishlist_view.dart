import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_colors.dart';
import '../../../app/router/route_constants.dart';
import '../../home/widgets/resource_card.dart';
import '../providers/favourites_provider.dart';

class WishlistView extends ConsumerWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favouriteItems = ref.watch(favouriteResourcesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Wishlist ❤️'),
      ),
      body: favouriteItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Favourited Resources Yet',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any resource card to save it here.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: favouriteItems.length,
              itemBuilder: (context, index) {
                final item = favouriteItems[index];
                return ResourceCard(
                  resource: item,
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.resourceDetailsName,
                      pathParameters: {'id': item.id},
                    );
                  },
                );
              },
            ),
    );
  }
}
