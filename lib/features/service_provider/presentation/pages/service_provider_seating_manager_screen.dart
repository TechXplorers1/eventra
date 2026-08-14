import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class ServiceProviderSeatingManagerScreen extends ConsumerStatefulWidget {
  const ServiceProviderSeatingManagerScreen({super.key});

  @override
  ConsumerState<ServiceProviderSeatingManagerScreen> createState() => _ServiceProviderSeatingManagerScreenState();
}

class _ServiceProviderSeatingManagerScreenState extends ConsumerState<ServiceProviderSeatingManagerScreen> {

  void _showAddSectionSheet() {
    final nameCtrl = TextEditingController();
    final rowsCtrl = TextEditingController();
    final seatsCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Seating Section', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                IconButton(icon: Icon(LucideIcons.x, color: AppColors.mutedForeground), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField('Section Name (e.g. VIP, Balcony)', nameCtrl, TextInputType.text),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildField('Rows', rowsCtrl, TextInputType.number)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Seats Per Row', seatsCtrl, TextInputType.number)),
              ],
            ),
            const SizedBox(height: 16),
            _buildField('Suggested Base Price', priceCtrl, TextInputType.number),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final rows = int.tryParse(rowsCtrl.text.trim()) ?? 0;
                  final seats = int.tryParse(seatsCtrl.text.trim()) ?? 0;
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
                  
                  if (name.isNotEmpty && rows > 0 && seats > 0) {
                    final section = SeatSection(
                      id: name.toLowerCase().replaceAll(' ', '_'),
                      name: name,
                      price: price,
                      colorHex: 0xFF9B66E0, // default purple
                      rows: rows,
                      seatsPerRow: seats,
                      available: rows * seats,
                    );
                    
                    final sp = ref.read(appProvider).serviceProvider;
                    final updatedLayouts = List<SeatSection>.from(sp.seatingLayouts)..add(section);
                    ref.read(appProvider.notifier).updateServiceProviderProfile(sp.copyWith(seatingLayouts: updatedLayouts));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Section', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: TextStyle(color: AppColors.foreground),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.secondary,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sp = ref.watch(appProvider).serviceProvider;
    final layouts = sp.seatingLayouts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => context.pop(),
        ),
        title: Text('Seating Manager', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
      ),
      body: layouts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.layoutGrid, size: 48, color: AppColors.mutedForeground),
                  const SizedBox(height: 16),
                  Text('No Seating Sections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 8),
                  Text('Define your physical layout to let attendees book seats.', style: TextStyle(color: AppColors.mutedForeground)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showAddSectionSheet,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('Add First Section', style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
              itemCount: layouts.length,
              itemBuilder: (context, index) {
                final sec = layouts[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: Color(sec.colorHex).withAlpha(50), borderRadius: BorderRadius.circular(8)),
                        child: Icon(LucideIcons.layoutGrid, color: Color(sec.colorHex)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sec.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.foreground)),
                            const SizedBox(height: 4),
                            Text('${sec.rows} Rows × ${sec.seatsPerRow} Seats (${sec.available} Total)', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.penTool, color: AppColors.primary, size: 20),
                        onPressed: () => _showLayoutDesigner(context, sec, index),
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
                        onPressed: () {
                          final sp = ref.read(appProvider).serviceProvider;
                          final updatedLayouts = List<SeatSection>.from(sp.seatingLayouts)..removeAt(index);
                          ref.read(appProvider.notifier).updateServiceProviderProfile(sp.copyWith(seatingLayouts: updatedLayouts));
                        },
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: layouts.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              onPressed: _showAddSectionSheet,
              child: const Icon(LucideIcons.plus, color: Colors.white),
            )
          : null,
    );
  }

  void _showLayoutDesigner(BuildContext context, SeatSection section, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) => _SeatingDesignerModal(section: section, index: index),
    );
  }
}

class _SeatingDesignerModal extends ConsumerStatefulWidget {
  final SeatSection section;
  final int index;

  const _SeatingDesignerModal({required this.section, required this.index});

  @override
  ConsumerState<_SeatingDesignerModal> createState() => _SeatingDesignerModalState();
}

class _SeatingDesignerModalState extends ConsumerState<_SeatingDesignerModal> {
  late List<String> _disabledSeats;

  @override
  void initState() {
    super.initState();
    _disabledSeats = List.from(widget.section.disabledSeats);
  }

  void _toggleSeat(String seatId) {
    setState(() {
      if (_disabledSeats.contains(seatId)) {
        _disabledSeats.remove(seatId);
      } else {
        _disabledSeats.add(seatId);
      }
    });
  }

  void _saveLayout() {
    final newAvailable = (widget.section.rows * widget.section.seatsPerRow) - _disabledSeats.length;
    final updatedSection = widget.section.copyWith(
      disabledSeats: _disabledSeats,
      available: newAvailable,
    );

    final sp = ref.read(appProvider).serviceProvider;
    final updatedLayouts = List<SeatSection>.from(sp.seatingLayouts);
    updatedLayouts[widget.index] = updatedSection;
    ref.read(appProvider.notifier).updateServiceProviderProfile(sp.copyWith(seatingLayouts: updatedLayouts));
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final sec = widget.section;
    final col = Color(sec.colorHex);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: AppColors.foreground),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Design: ${sec.name}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        actions: [
          TextButton(
            onPressed: _saveLayout,
            child: Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text('Tap seats to remove them (e.g. to create aisles or shape the layout). Disabled seats will be invisible to attendees.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),
          // Stage area marker
          Container(
            height: 40, width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100)),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: const Text('STAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white54)),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(sec.rows, (r) {
                      final rowLetter = String.fromCharCode(65 + r);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 20,
                              child: Text(rowLetter,
                                style: const TextStyle(fontSize: 9, color: Colors.white38))),
                            const SizedBox(width: 6),
                            ...List.generate(sec.seatsPerRow, (c) {
                              final seatId = '$rowLetter${c + 1}';
                              final isDisabled = _disabledSeats.contains(seatId);

                              return GestureDetector(
                                onTap: () => _toggleSeat(seatId),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 22, height: 22,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: isDisabled ? Colors.transparent : col,
                                    border: Border.all(color: isDisabled ? AppColors.border : col, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  alignment: Alignment.center,
                                  child: isDisabled
                                    ? Icon(LucideIcons.x, size: 12, color: AppColors.border)
                                    : Text('${c + 1}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legend('Active', col),
                const SizedBox(width: 24),
                _legend('Disabled (Invisible)', Colors.transparent, hasBorder: true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _legend(String label, Color color, {bool hasBorder = false}) {
    return Row(
      children: [
        Container(
          width: 14, height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: AppColors.border) : null,
          ),
          child: hasBorder ? Icon(LucideIcons.x, size: 8, color: AppColors.border) : null,
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
      ],
    );
  }
}
