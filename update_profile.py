import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_profile_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the Stats Row
old_stats_row = """                    // Stats Row
                    Row(children: [
                      _HeroStat(value: rating.toStringAsFixed(1), label: 'Rating', icon: LucideIcons.star),
                      _heroDivider(),
                      _HeroStat(value: '${sp.totalGigs}', label: 'Gigs', icon: LucideIcons.calendarCheck),
                      _heroDivider(),
                      _HeroStat(value: '$confirmed', label: 'Active', icon: LucideIcons.zap),
                      _heroDivider(),
                      _HeroStat(value: '${sp.experienceYears}y', label: 'Experience', icon: LucideIcons.award),
                    ]),"""

new_stats_row = """                    // Stats Row
                    Row(children: [
                      _HeroStat(value: rating.toStringAsFixed(1), label: 'Rating', icon: LucideIcons.star),
                      _heroDivider(),
                      _HeroStat(value: '${sp.totalGigs}', label: 'Gigs', icon: LucideIcons.calendarCheck),
                      _heroDivider(),
                      _HeroStat(value: '$confirmed', label: 'Active', icon: LucideIcons.zap),
                      _heroDivider(),
                      if (sp.venueType.isNotEmpty || sp.capacity > 0)
                        _HeroStat(value: '${sp.capacity}', label: 'Capacity', icon: LucideIcons.users)
                      else
                        _HeroStat(value: '${sp.experienceYears}y', label: 'Experience', icon: LucideIcons.award),
                    ]),"""

content = content.replace(old_stats_row, new_stats_row)

# Also let's show layout/amenities if it's a venue
old_bio_section = """                      if (sp.bio.isNotEmpty) ...[
                        Text(sp.bio, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.5)),
                        const SizedBox(height: 8),
                      ],
                      if (sp.city.isNotEmpty)"""

new_bio_section = """                      if (sp.bio.isNotEmpty) ...[
                        Text(sp.bio, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.5)),
                        const SizedBox(height: 8),
                      ],
                      if (sp.address.isNotEmpty) ...[
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Icon(LucideIcons.map, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(child: Text(sp.address, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                        ]),
                        const SizedBox(height: 8),
                      ],
                      if (sp.amenities.isNotEmpty) ...[
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: sp.amenities.map((a) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
                            child: Text(a, style: TextStyle(fontSize: 10, color: AppColors.foreground)),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (sp.city.isNotEmpty)"""

content = content.replace(old_bio_section, new_bio_section)


with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Profile screen updated")
