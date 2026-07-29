import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class OrganizerServiceRequestsScreen extends ConsumerWidget {
  const OrganizerServiceRequestsScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Quote Requested': return Colors.amber;
      case 'Quotes Received': return Colors.blue;
      case 'Vendor Selected': return Colors.purpleAccent;
      case 'Confirmed': return Colors.greenAccent;
      case 'Cancelled': return Colors.redAccent;
      default: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceRequests = ref.watch(appProvider).serviceRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('My Service Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('${serviceRequests.length} requests', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: serviceRequests.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                              child: Icon(LucideIcons.inbox, size: 28, color: AppColors.mutedForeground),
                            ),
                            const SizedBox(height: 16),
                            Text('No service requests yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            const SizedBox(height: 4),
                            Text('Browse services to request quotes from vendors.', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.push('/organizer/services'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.primaryForeground,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Browse Services', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: serviceRequests.length,
                      itemBuilder: (context, index) {
                        final request = serviceRequests[index];
                        final category = allUserServices.firstWhere((c) => c.id == request.categoryId, orElse: () => allUserServices[0]);
                        final statusColor = _getStatusColor(request.status);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40, height: 40,
                                        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                                        child: Icon(category.icon, size: 16, color: AppColors.primaryForeground),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(category.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                          Text(request.vendorName ?? '${request.quotes} quote${request.quotes == 1 ? '' : 's'} received', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                    child: Text(request.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _buildStat('Budget', '₹${request.budget.toStringAsFixed(0)}')),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStat('Pros', '${request.professionals}')),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildStat('Duration', request.duration)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              request.status == 'Cancelled'
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => context.push('/organizer/services/providers/${request.categoryId}'),
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.primaryForeground, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                            child: const Text('Find Another Provider', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.foreground, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                            child: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => ref.read(appProvider.notifier).updateServiceRequestStatus(request.id, 'Cancelled'),
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                            child: const Text('Cancel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    );
  }
}
