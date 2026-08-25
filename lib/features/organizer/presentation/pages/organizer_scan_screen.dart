import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class OrganizerScanScreen extends ConsumerStatefulWidget {
  const OrganizerScanScreen({super.key});

  @override
  ConsumerState<OrganizerScanScreen> createState() => _OrganizerScanScreenState();
}

class _OrganizerScanScreenState extends ConsumerState<OrganizerScanScreen> with SingleTickerProviderStateMixin {
  bool _flash = false;
  String? _scanResult; // 'success' or 'error'
  BookedTicket? _matchedTicket;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _simulateScan(String type) {
    final bookedTickets = ref.read(appProvider).bookedTickets;
    BookedTicket? found;
    if (type == 'success' && bookedTickets.isNotEmpty) {
      found = bookedTickets.first;
    }
    setState(() {
      _scanResult = type;
      _matchedTicket = found;
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _scanResult = null;
          _matchedTicket = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                            Text('Scan Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // Scanner viewport
                              Expanded(
                                child: Container(
                                  constraints: const BoxConstraints(minHeight: 200),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Positioned(
                                        top: 32, bottom: 32, left: 32, right: 32,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                      ),
                                      Icon(LucideIcons.camera, size: 48, color: AppColors.mutedForeground.withOpacity(0.3)),

                                      // Scanning line
                                      Positioned(
                                        top: 32, bottom: 32, left: 32, right: 32,
                                        child: AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Align(
                                              alignment: Alignment(0, -1.0 + (_pulseController.value * 2.0)),
                                              child: Container(
                                                height: 2,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 8)],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      // Result overlay
                                      if (_scanResult != null)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: _scanResult == 'success' ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _scanResult == 'success' ? LucideIcons.checkCircle : LucideIcons.xCircle,
                                                  size: 64,
                                                  color: _scanResult == 'success' ? Colors.greenAccent : Colors.redAccent,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _scanResult == 'success' ? 'Valid Ticket ✓' : 'Invalid Ticket ✗',
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _scanResult == 'success' ? Colors.greenAccent : Colors.redAccent),
                                                ),
                                                if (_matchedTicket != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(_matchedTicket!.eventTitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                                  Text('${_matchedTicket!.ticketType} • Qty: ${_matchedTicket!.quantity}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                                  const SizedBox(height: 2),
                                                  Text('QR: ${_matchedTicket!.qrCode}', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                                ] else if (_scanResult == 'error') ...[
                                                  const SizedBox(height: 4),
                                                  const Text('Not found in booked tickets', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Flash toggle
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  onTap: () => setState(() => _flash = !_flash),
                                  borderRadius: BorderRadius.circular(24),
                                  child: Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                    child: Icon(_flash ? LucideIcons.flashlight : LucideIcons.flashlightOff, size: 18, color: _flash ? AppColors.primary : AppColors.mutedForeground),
                                  ),
                                ),
                              ),

                              // Demo: simulate scan vs actual booked tickets
                              Text('Demo: Simulate scan with real ticket data', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _simulateScan('success'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.withOpacity(0.1),
                                        foregroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Valid Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => _simulateScan('error'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        foregroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Invalid Ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
