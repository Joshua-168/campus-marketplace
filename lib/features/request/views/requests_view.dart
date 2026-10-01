import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../domain/entities/request_entity.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/request_provider.dart';
import '../widgets/request_card.dart';

class RequestsView extends ConsumerStatefulWidget {
  const RequestsView({super.key});

  @override
  ConsumerState<RequestsView> createState() => _RequestsViewState();
}

class _RequestsViewState extends ConsumerState<RequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  RequestStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authNotifierProvider).user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Requests')),
        body: const EmptyStateView(
          icon: Icons.lock_outline_rounded,
          title: 'Sign In Required',
          description: 'Please sign in to view your sent and received campus resource requests.',
        ),
      );
    }

    final sentRequestsAsync = ref.watch(sentRequestsStreamProvider(user.id));
    final receivedRequestsAsync = ref.watch(receivedRequestsStreamProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Requests'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: theme.brightness == Brightness.dark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          tabs: const [
            Tab(text: 'Sent Requests'),
            Tab(text: 'Received Requests'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Pills Row (All, Pending, Approved, Rejected)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Statuses'),
                      selected: _statusFilter == null,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: _statusFilter == null ? Colors.white : AppColors.textPrimaryLight,
                        fontWeight: _statusFilter == null ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => _statusFilter = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    ...RequestStatus.values.map((status) {
                      final isSelected = _statusFilter == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(status.displayName),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() => _statusFilter = selected ? status : null);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Sent Requests
                  sentRequestsAsync.when(
                    data: (list) {
                      final filtered = _statusFilter == null
                          ? list
                          : list.where((item) => item.status == _statusFilter).toList();

                      if (filtered.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.swap_horiz_rounded,
                          title: 'No Sent Requests',
                          description: 'You haven\'t requested to borrow any campus items yet.',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return RequestCard(
                            request: filtered[index],
                            isReceived: false,
                          );
                        },
                      );
                    },
                    loading: () => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (_, _) => ShimmerLoading.listTileSkeleton(),
                    ),
                    error: (err, stack) => ErrorView(message: err.toString()),
                  ),

                  // Tab 2: Received Requests
                  receivedRequestsAsync.when(
                    data: (list) {
                      final filtered = _statusFilter == null
                          ? list
                          : list.where((item) => item.status == _statusFilter).toList();

                      if (filtered.isEmpty) {
                        return const EmptyStateView(
                          icon: Icons.inbox_outlined,
                          title: 'No Received Requests',
                          description: 'No student requests have been submitted for your listed items yet.',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return RequestCard(
                            request: item,
                            isReceived: true,
                            onStatusUpdate: (newStatus) async {
                              final success = await ref
                                  .read(requestNotifierProvider.notifier)
                                  .updateStatus(
                                    requestId: item.id,
                                    status: newStatus,
                                  );

                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Request marked as ${newStatus.displayName}!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (_, _) => ShimmerLoading.listTileSkeleton(),
                    ),
                    error: (err, stack) => ErrorView(message: err.toString()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
