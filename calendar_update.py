import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_calendar_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Make sure we don't have syntax errors with `withOpacity` vs `.withAlpha` (though `withOpacity` just causes infos, replacing them is better).
content = content.replace('.withOpacity(', '.withAlpha(')

old_gig_tile = """class _GigTile extends StatelessWidget {
  final ServiceRequest gig;
  const _GigTile({required this.gig});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(0.25)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(LucideIcons.briefcase, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(gig.eventName.isNotEmpty ? gig.eventName : gig.categoryName,
              style: TextStyle(color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            '${gig.categoryName}  •  ₹${gig.budget.toInt()}  •  ${gig.duration}',
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
          ),
          if (gig.eventVenue.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(children: [
              Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
              const SizedBox(width: 3),
              Expanded(child: Text(gig.eventVenue,
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ],
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withAlpha(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Confirmed',
              style: const TextStyle(color: Color(0xFF22C55E), fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}"""

new_gig_tile = """class _GigTile extends StatelessWidget {
  final ServiceRequest gig;
  const _GigTile({required this.gig});

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(gig.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confirmed',
                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(gig.eventName.isNotEmpty ? gig.eventName : 'Event Details TBD', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(LucideIcons.mapPin, gig.eventVenue.isNotEmpty ? gig.eventVenue : 'Location TBD'),
                _badge(LucideIcons.indianRupee, '₹${gig.budget.toInt()}'),
                _badge(LucideIcons.clock, gig.duration),
              ],
            ),
          ],
        ),
      ),
    );
  }
}"""

# But because I replaced .withOpacity(0.08) with .withAlpha(0.08), the floating point might cause an issue or not match.
# Better to do a regex or just simple string replace.
import re

content = re.sub(r'class _GigTile extends StatelessWidget \{.*?Widget build\(BuildContext context\) \{.*?\n  \}\n\}', new_gig_tile, content, flags=re.DOTALL)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated calendar")
