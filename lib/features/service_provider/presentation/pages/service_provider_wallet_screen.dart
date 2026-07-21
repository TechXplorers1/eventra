import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class ServiceProviderWalletScreen extends ConsumerWidget {
  const ServiceProviderWalletScreen({super.key});

  void _showWithdrawSheet(BuildContext context, WidgetRef ref, double balance) {
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
            Text('Withdraw Funds', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 4),
            Text('Available: ₹${balance.toInt()} • 2% platform fee applies', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
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
            Text('To Axis Bank ****8812 • usually in 1 business day', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(ctrl.text) ?? 0;
                  if (amount > 0 && amount <= balance) {
                    ref.read(appProvider.notifier).requestSPWithdrawal(amount);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Withdrawal of ₹${amount.toInt()} initiated!'),
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
                child: Text('Confirm Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
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
    final balance = appState.spWalletBalance;
    final transactions = appState.spTransactions;
    final totalEarned = transactions
        .where((t) => t.type == 'credit')
        .fold<double>(0.0, (sum, t) => sum + t.amount);
    final nextPayout = (balance * 0.3).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Wallet', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Balance card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available Balance', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.8), fontSize: 14)),
                          Icon(LucideIcons.wallet, color: AppColors.primaryForeground.withOpacity(0.8), size: 20),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('₹${balance.toInt()}', style: TextStyle(color: AppColors.primaryForeground, fontSize: 36, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Total Earned: ₹${totalEarned.toInt()}', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.7), fontSize: 12)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: balance > 0 ? () => _showWithdrawSheet(context, ref, balance) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryForeground,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Withdraw Funds', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Next payout info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.arrowDownToLine, color: Colors.green),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Auto Payout', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('₹$nextPayout scheduled this Friday', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Transactions
                Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 16),
                if (transactions.isEmpty)
                  Center(child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text('No transactions yet', style: TextStyle(color: AppColors.mutedForeground)),
                  ))
                else
                  ...transactions.map((t) {
                    final isCredit = t.type == 'credit';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCredit ? Colors.green.withOpacity(0.1) : AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(isCredit ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, color: isCredit ? Colors.green : AppColors.foreground, size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.label, style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(t.date, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            '${isCredit ? '+' : '-'}₹${t.amount.toInt()}',
                            style: TextStyle(color: isCredit ? Colors.green : AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }
}
