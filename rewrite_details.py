import os

filepath = r'd:\company-work\eventra\lib\features\organizer\presentation\pages\organizer_event_detail_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# We need to import service_providers_data.dart
import_statement = "import '../../../../core/data/service_providers_data.dart';"
if import_statement not in content:
    content = content.replace("import '../../../../core/data/venues_data.dart';", "import '../../../../core/data/venues_data.dart';\n" + import_statement)

# Replace the button logic in _buildServicesTab
services_btn_old = """        ElevatedButton(
          onPressed: () => context.push('/organizer/services'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('+ Request New Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),"""
services_btn_new = """        ElevatedButton(
          onPressed: () => _showServiceOptionsPicker(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('+ Request New Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),"""
content = content.replace(services_btn_old, services_btn_new)

# Replace _showVenuePicker and add the new methods before _buildServicesTab
venue_picker_old_start = "  void _showVenuePicker(EventData event) {"
venue_picker_old_end = "  Widget _buildServicesTab(List<ServiceRequest> serviceRequests, double totalSpend, int pending) {"

old_idx_start = content.find(venue_picker_old_start)
old_idx_end = content.find(venue_picker_old_end)
if old_idx_start != -1 and old_idx_end != -1:
    new_methods = """  void _showVenuePicker(EventData event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select New Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.x, color: AppColors.foreground),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mockVenues.length,
                    itemBuilder: (context, index) {
                      final venue = mockVenues[index];
                      return _buildVenueCard(venue, event, context);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVenueCard(VenueData venue, EventData event, BuildContext modalContext) {
    final selected = event.linkedVenueId == venue.id;
    return GestureDetector(
      onTap: () => _showVenuePortfolio(venue, event, modalContext),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Image.network(venue.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 120, color: AppColors.secondary, child: Icon(LucideIcons.building2, color: AppColors.mutedForeground, size: 36)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(venue.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                if (selected) Icon(LucideIcons.checkCircle2, size: 20, color: AppColors.primary),
              ]),
              const SizedBox(height: 3),
              Row(children: [Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground), const SizedBox(width: 4), Text('${venue.address}, ${venue.city}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: [
                _venueBadge(LucideIcons.users, '${venue.capacity} guests'),
                _venueBadge(LucideIcons.star, '${venue.rating}'),
                _venueBadge(LucideIcons.indianRupee, '₹${(venue.pricePerDay / 1000).toStringAsFixed(0)}K/day'),
              ]),
              if (venue.amenities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(venue.amenities.take(3).join(' · '), style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _venueBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _showVenuePortfolio(VenueData venue, EventData event, BuildContext modalContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      venue.imageUrl, 
                      height: 250, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 250, color: AppColors.secondary, child: Icon(LucideIcons.building2, color: AppColors.mutedForeground, size: 48)),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(venue.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${venue.address}, ${venue.city}', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _venueBadge(LucideIcons.users, '${venue.capacity} guests'),
                        _venueBadge(LucideIcons.star, '${venue.rating}'),
                        _venueBadge(LucideIcons.indianRupee, '₹${(venue.pricePerDay / 1000).toStringAsFixed(0)}K/day'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Text(venue.description, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    const SizedBox(height: 24),
                    Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: venue.amenities.map((a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                        child: Text(a, style: TextStyle(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final updatedEvent = event.copyWith(
                      venue: venue.name,
                      city: venue.city,
                      linkedVenueId: venue.id,
                      venueStatus: 'Pending',
                    );
                    ref.read(appProvider.notifier).updateEvent(updatedEvent);
                    Navigator.pop(context); // close portfolio
                    Navigator.pop(modalContext); // close picker list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Venue change requested successfully!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Venue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServiceOptionsPicker() {
    final _serviceOptions = ['Photography', 'Catering', 'DJ / Sound', 'Decoration', 'Security', 'Videography', 'MC / Host', 'Stage & Lighting'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request New Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: _serviceOptions.map((s) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showProvidersModal(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showProvidersModal(String category) {
    final providers = mockServiceProviders.where((p) => p.serviceCategory == category).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$category Providers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    GestureDetector(onTap: () => Navigator.pop(context), child: Icon(LucideIcons.x, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              Divider(color: AppColors.border, height: 1),
              Expanded(
                child: providers.isEmpty 
                  ? Center(child: Text('No providers found in this category.', style: TextStyle(color: AppColors.mutedForeground)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final p = providers[index];
                        return GestureDetector(
                          onTap: () => _showProviderPortfolio(p, context),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.secondary,
                                  child: Icon(LucideIcons.user, color: AppColors.mutedForeground),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.businessName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      const SizedBox(height: 4),
                                      Text('${p.fullName} • ⭐ ${p.rating}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                      const SizedBox(height: 6),
                                      Text('From ₹${p.startingPrice}', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Icon(LucideIcons.chevronRight, size: 20, color: AppColors.mutedForeground),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProviderPortfolio(ServiceProviderProfile provider, BuildContext modalContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(LucideIcons.image, size: 48, color: AppColors.mutedForeground)),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(provider.fullName[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.businessName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              const SizedBox(height: 4),
                              Text('${provider.serviceCategory} • ${provider.experience} exp', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Text(provider.bio, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Starting from', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text('₹${provider.startingPrice}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(LucideIcons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${provider.rating}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text(' (${provider.jobsCompleted} jobs)', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final req = ServiceRequest(
                      id: 'SR${DateTime.now().millisecondsSinceEpoch}',
                      eventId: widget.eventId,
                      organizerId: 'O001',
                      vendorId: provider.id,
                      categoryName: provider.serviceCategory,
                      vendorName: provider.businessName,
                      vendorPrice: provider.startingPrice,
                      status: 'Quote Requested',
                      requestDate: DateTime.now().toIso8601String(),
                    );
                    ref.read(appProvider.notifier).addServiceRequest(req);
                    Navigator.pop(context); // close portfolio
                    Navigator.pop(modalContext); // close picker list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service requested successfully!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Request Quote', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

"""
    content = content[:old_idx_start] + new_methods + content[old_idx_end:]

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
