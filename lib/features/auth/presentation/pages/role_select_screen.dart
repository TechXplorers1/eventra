import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _roles = [
    {
      'id': Role.attendee,
      'title': 'Attendee',
      'subtitle': 'Discover events, buy tickets, and experience the extraordinary.',
      'icon': LucideIcons.ticket,
      'color': Colors.blueAccent,
    },
    {
      'id': Role.organizer,
      'title': 'Organizer',
      'subtitle': 'Create, manage, and host incredible events effortlessly.',
      'icon': LucideIcons.calendarCheck2,
      'color': Colors.deepPurpleAccent,
    },
    {
      'id': Role.service,
      'title': 'Service Provider',
      'subtitle': 'Offer venues, catering, equipment, and services to organizers.',
      'icon': LucideIcons.store,
      'color': Colors.teal,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleRoleSelect(Role roleId) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      ref.read(appProvider.notifier).setRole(roleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Gradient matching the current card
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.5),
                radius: 1.5,
                colors: [
                  _roles[_currentIndex]['color'].withOpacity(0.3),
                  Colors.black,
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Choose Your Path',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'How would you like to use Eventra today?',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                  ),
                ),
                const SizedBox(height: 48),
                
                // Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      final isSelected = _currentIndex == index;
                      
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: AnimatedOpacity(
                          opacity: isSelected ? 1.0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: GestureDetector(
                            onTap: () {
                              if (!isSelected) {
                                _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: isSelected ? role['color'] : AppColors.border.withOpacity(0.5), width: isSelected ? 2 : 1),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: role['color'].withOpacity(0.2), blurRadius: 40, offset: const Offset(0, 20))
                                ] : [],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Stack(
                                  children: [
                                    // Abstract shape in card
                                    Positioned(
                                      top: -50, right: -50,
                                      child: Container(
                                        width: 200, height: 200,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [role['color'].withOpacity(0.2), Colors.transparent],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: role['color'].withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Icon(role['icon'], size: 48, color: role['color']),
                                          ),
                                          const Spacer(),
                                          Text(
                                            role['title'],
                                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.foreground, letterSpacing: -0.5),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            role['subtitle'],
                                            style: TextStyle(fontSize: 16, color: AppColors.mutedForeground, height: 1.4),
                                          ),
                                          const SizedBox(height: 32),
                                          
                                          // Action Button inside card
                                          InkWell(
                                            onTap: isSelected ? () => _handleRoleSelect(role['id']) : null,
                                            borderRadius: BorderRadius.circular(16),
                                            child: Container(
                                              height: 64,
                                              decoration: BoxDecoration(
                                                color: role['color'],
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Center(
                                                child: _isLoading && isSelected
                                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                                    : Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          const Text('Continue as ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                                          Text(role['title'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                                          const SizedBox(width: 8),
                                                          const Icon(LucideIcons.arrowRight, color: Colors.white, size: 20),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Page Indicators
                Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_roles.length, (index) {
                      final isSelected = _currentIndex == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: isSelected ? 24 : 6,
                        decoration: BoxDecoration(
                          color: isSelected ? _roles[_currentIndex]['color'] : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
