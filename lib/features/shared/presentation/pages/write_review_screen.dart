import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String id;
  const WriteReviewScreen({super.key, required this.id});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);
    
    // Simulate network request
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(LucideIcons.checkCircle2, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Review submitted successfully!'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => context.pop(),
        ),
        title: Text('Write a Review', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'How was your experience?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
            ),
            const SizedBox(height: 8),
            Text(
              'Your feedback helps us improve and helps others make better choices.',
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 48),
            
            // Star Rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final isSelected = index < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = index + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? LucideIcons.star : LucideIcons.star,
                          size: 48,
                          color: isSelected ? Colors.amber : AppColors.border,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 48),
            
            // Review Text
            Text('Share details of your experience', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _reviewController,
                maxLines: 5,
                style: TextStyle(color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'What went well? What could be improved?',
                  hintStyle: TextStyle(color: AppColors.mutedForeground),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Submit Button
            GestureDetector(
              onTap: _rating > 0 && !_isSubmitting ? _handleSubmit : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _rating > 0 && !_isSubmitting ? 1.0 : 0.5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Submit Review', style: TextStyle(color: AppColors.primaryForeground, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
