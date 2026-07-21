import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class ServicesMarketplaceScreen extends StatefulWidget {
  const ServicesMarketplaceScreen({super.key});

  @override
  State<ServicesMarketplaceScreen> createState() => _ServicesMarketplaceScreenState();
}

class _ServicesMarketplaceScreenState extends State<ServicesMarketplaceScreen> {
  String _query = '';
  String _activeGroup = 'all';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    
    final groups = _activeGroup == 'all' 
        ? serviceGroups 
        : serviceGroups.where((g) => g.id == _activeGroup).toList();

    final filteredGroups = q.isEmpty 
        ? groups 
        : groups.map((g) {
            final filteredServices = g.services.where((s) => 
                s.name.toLowerCase().contains(q) || 
                s.description.toLowerCase().contains(q) || 
                g.name.toLowerCase().contains(q)).toList();
            return ServiceGroup(id: g.id, name: g.name, services: filteredServices);
          }).where((g) => g.services.isNotEmpty).toList();

    final totalCount = filteredGroups.fold<int>(0, (sum, g) => sum + g.services.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Eventra Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Marketplace · ${allUserServices.length} services', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search services, vendors, or categories...',
                          hintStyle: TextStyle(color: AppColors.mutedForeground),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _query = ''),
                        child: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Group chips
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [{'id': 'all', 'name': 'All'}, ...serviceGroups.map((g) => {'id': g.id, 'name': g.name})].map((chip) {
                  final isSelected = _activeGroup == chip['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _activeGroup = chip['id']!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                          color: isSelected ? null : AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(chip['name']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Results
            Expanded(
              child: totalCount == 0
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No services found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          const SizedBox(height: 4),
                          Text('Try a different search or category.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filteredGroups.length,
                      itemBuilder: (context, i) {
                        final group = filteredGroups[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(group.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text('${group.services.length}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GridView.count(
                                crossAxisCount: 3,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8,
                                children: group.services.map((s) {
                                  return InkWell(
                                    onTap: () {
                                      if (s.id == 'banquet-hall') {
                                        context.push('/banquet-halls');
                                      } else {
                                        context.push('/services/${s.id}');
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 40, height: 40,
                                            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                                            child: Icon(s.icon, size: 20, color: AppColors.primaryForeground),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(s.name, textAlign: TextAlign.center, maxLines: 2, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.foreground)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
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
}
