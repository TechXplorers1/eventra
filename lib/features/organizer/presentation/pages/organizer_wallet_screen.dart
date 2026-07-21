import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class OrganizerWalletScreen extends ConsumerWidget {
  const OrganizerWalletScreen({super.key});

  void _showPayoutSheet(BuildContext context, WidgetRef ref, double balance) {
    final ctrl = TextEditingController(text: (balance * 0.8).toInt().toString());
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
            Text('Request Payout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 4),
            Text('Available: ₹${balance.toInt()}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Enter amount',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
            const SizedBox(height: 8),
            Text('Payout to HDFC Bank ****4321 • usually in 2 business days', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text) ?? 0;
                  if (amount > 0 && amount <= balance) {
                    ref.read(appProvider.notifier).requestOrganizerPayout(amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Payout of ₹${amount.toInt()} requested!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Confirm Payout', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final balance = appState.organizerWalletBalance;
    final transactions = appState.organizerTransactions;
    final totalEarned = transactions
        .where((t) => t.type == 'credit')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final pendingAmount = appState.bookedTickets
        .where((t) => t.bookedAt == DateTime.now().toIso8601String().substring(0, 10))
        .fold<double>(0.0, (sum, t) => sum + t.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Wallet & Payouts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ],
              ),
            ),

            // Balance card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Available Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryForeground.withOpacity(0.7))),
                    const SizedBox(height: 4),
                    Text('₹${balance.toInt()}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryForeground)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pending', style: TextStyle(fontSize: 10, color: AppColors.primaryForeground.withOpacity(0.6))),
                              Text(pendingAmount > 0 ? '₹${pendingAmount.toInt()}' : '₹0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total Earned', style: TextStyle(fontSize: 10, color: AppColors.primaryForeground.withOpacity(0.6))),
                              Text('₹${totalEarned.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Payout button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: balance > 0 ? () => _showPayoutSheet(context, ref, balance) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.foreground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.building2, size: 16),
                    const SizedBox(width: 8),
                    Text('Request Payout', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Icon(LucideIcons.chevronRight, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Transactions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transaction History', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 12),
                  if (transactions.isEmpty)
                    Center(child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text('No transactions yet', style: TextStyle(color: AppColors.mutedForeground)),
                    ))
                  else
                    ...transactions.map((t) {
                      final isCredit = t.type == 'credit';
                      final color = isCredit ? Colors.greenAccent : Colors.redAccent;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, size: 18, color: color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground)),
                                  Text(t.date, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : '-'}₹${t.amount.toInt()}',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
