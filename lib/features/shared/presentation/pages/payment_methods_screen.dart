import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class _Card {
  final String id;
  final String type;
  final String last4;
  final String expiry;
  final String name;
  final bool isDefault;

  _Card({required this.id, required this.type, required this.last4, required this.expiry, required this.name, required this.isDefault});
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_Card> _cards = [
    _Card(id: '1', type: 'visa', last4: '4242', expiry: '12/26', name: 'Rahul Sharma', isDefault: true),
    _Card(id: '2', type: 'mastercard', last4: '8888', expiry: '09/25', name: 'Rahul Sharma', isDefault: false),
  ];

  void _setDefault(String id) {
    setState(() {
      for (var i = 0; i < _cards.length; i++) {
        _cards[i] = _Card(
          id: _cards[i].id,
          type: _cards[i].type,
          last4: _cards[i].last4,
          expiry: _cards[i].expiry,
          name: _cards[i].name,
          isDefault: _cards[i].id == id,
        );
      }
    });
  }

  void _deleteCard(String id) {
    setState(() {
      _cards.removeWhere((c) => c.id == id);
    });
  }

  void _showAddCardModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AddCardModal(),
    ).then((newCard) {
      if (newCard != null && newCard is _Card) {
        setState(() {
          _cards.add(newCard);
        });
      }
    });
  }

  void _showDeleteConfirm(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove Card?', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
        content: Text('This card will be permanently removed from your account.', style: TextStyle(color: AppColors.mutedForeground)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.foreground)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCard(id);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Payment Methods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Wallet
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('EVENTRA WALLET', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text('₹2,450', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('Available Balance', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                                child: const Text('Add Money', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
                                child: const Text('Withdraw', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Saved Cards
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saved Cards', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        InkWell(
                          onTap: _showAddCardModal,
                          child: Row(
                            children: [
                              Icon(LucideIcons.plus, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text('Add New', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ..._cards.map((c) => _buildCard(c)),
                    
                    InkWell(
                      onTap: _showAddCardModal,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Add Credit / Debit Card', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // UPI Apps
                    Text('UPI Apps', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 12),
                    _buildUpiItem('Google Pay', 'rahul@okaxis', '🟢'),
                    const SizedBox(height: 8),
                    _buildUpiItem('PhonePe', 'rahul@ybl', '🟣'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.smartphone, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Link UPI ID', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Net Banking
                    Text('Net Banking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.building2, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Add Bank Account', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_Card card) {
    final colors = card.type == 'visa'
        ? [Colors.blue.shade900, AppColors.primary]
        : [Colors.orange.shade900, Colors.red.shade900];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.creditCard, color: AppColors.primaryForeground, size: 20),
                  const SizedBox(width: 8),
                  Text(card.type.toUpperCase(), style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  if (card.isDefault)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                      child: const Text('Default', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  InkWell(
                    onTap: () => _showDeleteConfirm(card.id),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: AppColors.destructive.withOpacity(0.2), shape: BoxShape.circle),
                      child: Icon(LucideIcons.trash2, size: 14, color: AppColors.destructive),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('•••• •••• •••• ${card.last4}', style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 4, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CARDHOLDER', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(card.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('EXPIRES', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  Text(card.expiry, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          if (!card.isDefault) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _setDefault(card.id),
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle2, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  const Text('Set as Default', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpiItem(String name, String handle, String icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w500, fontSize: 14)),
                Text(handle, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.destructive.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(LucideIcons.trash2, size: 14, color: AppColors.destructive),
          ),
        ],
      ),
    );
  }
}

class _AddCardModal extends StatefulWidget {
  const _AddCardModal();

  @override
  State<_AddCardModal> createState() => _AddCardModalState();
}

class _AddCardModalState extends State<_AddCardModal> {
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _saved = false;

  void _save() {
    if (_numCtrl.text.isEmpty || _nameCtrl.text.isEmpty) return;
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      final card = _Card(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: 'visa',
        last4: _numCtrl.text.length > 4 ? _numCtrl.text.substring(_numCtrl.text.length - 4) : '0000',
        expiry: _expCtrl.text,
        name: _nameCtrl.text,
        isDefault: false,
      );
      Navigator.pop(context, card);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add New Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.muted, shape: BoxShape.circle),
                    child: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_saved)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(LucideIcons.check, size: 32, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  Text('Card Added Successfully!', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                ],
              )
            else
              Column(
                children: [
                  TextField(
                    controller: _numCtrl,
                    style: TextStyle(color: AppColors.foreground),
                    decoration: InputDecoration(
                      hintText: 'Card Number',
                      hintStyle: TextStyle(color: AppColors.mutedForeground),
                      filled: true,
                      fillColor: AppColors.input,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(color: AppColors.foreground),
                    decoration: InputDecoration(
                      hintText: 'Cardholder Name',
                      hintStyle: TextStyle(color: AppColors.mutedForeground),
                      filled: true,
                      fillColor: AppColors.input,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _expCtrl,
                          style: TextStyle(color: AppColors.foreground),
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            hintStyle: TextStyle(color: AppColors.mutedForeground),
                            filled: true,
                            fillColor: AppColors.input,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cvvCtrl,
                          style: TextStyle(color: AppColors.foreground),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            hintStyle: TextStyle(color: AppColors.mutedForeground),
                            filled: true,
                            fillColor: AppColors.input,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Add Card Securely', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
