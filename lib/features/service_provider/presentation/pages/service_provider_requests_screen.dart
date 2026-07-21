import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/models/app_models.dart';

class ServiceProviderRequestsScreen extends ConsumerStatefulWidget {
  const ServiceProviderRequestsScreen({super.key});

  @override
  ConsumerState<ServiceProviderRequestsScreen> createState() => _ServiceProviderRequestsScreenState();
}

class _ServiceProviderRequestsScreenState extends ConsumerState<ServiceProviderRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    final appState = ref.watch(appProvider);
    final vendorId = appState.serviceProvider.vendorId.isNotEmpty ? appState.serviceProvider.vendorId : 'v1';
    // Pending = no vendor assigned (open requests SP can bid on)
    // Active = confirmed/assigned requests belonging to this SP
    final requests = appState.serviceRequests.where((r) => r.vendorId == vendorId || r.vendorId == null || r.vendorId!.isEmpty).toList();
    
    final pending = requests.where((r) => r.status == 'Quote Requested').toList();
    final active = requests.where((r) => r.status == 'Confirmed' || r.status == 'Vendor Selected').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Booking Requests', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'New (${pending.length})'),
            Tab(text: 'Active (${active.length})'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(pending, true),
              _buildRequestsList(active, false),
            ],
          ),
          const BottomNav(),
        ],
      ),
    );
  }


  void _showQuoteDialog(BuildContext context, ServiceRequest req) {
    final priceCtrl = TextEditingController(text: req.budget.toInt().toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Send Quote', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 4),
            Text('${req.categoryName} • Client budget: ₹${req.budget.toInt()}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Your price',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? req.budget;
                  ref.read(appProvider.notifier).acceptServiceRequest(
                    req.id,
                    ref.read(appProvider).serviceProvider.businessName,
                    price,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Quote of ₹${price.toInt()} submitted!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(List<ServiceRequest> list, bool isPending) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No requests found', style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final req = list[index];
        return _buildRequestCard(req, isPending);
      },
    );
  }

  Widget _buildRequestCard(ServiceRequest req, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(req.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.status,
                  style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Expanded(child: Text(
                req.eventName.isNotEmpty ? '${req.eventName} • ${req.eventDate}' : 'Coming up soon',
                style: TextStyle(color: AppColors.foreground, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          const SizedBox(height: 8),
          if (req.eventVenue.isNotEmpty)
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
                const SizedBox(width: 8),
                Expanded(child: Text(req.eventVenue, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13), overflow: TextOverflow.ellipsis)),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(LucideIcons.users, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Text('${req.professionals} Professionals • ${req.duration}', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Client Budget', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                Text('₹${req.budget.toInt()}', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(appProvider.notifier).declineServiceRequest(req.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Request declined'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Decline', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showQuoteDialog(context, req),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Send Quote', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
