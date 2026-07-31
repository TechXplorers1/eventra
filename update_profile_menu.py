import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_profile_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add Seating menu item conditionally
old_menu = """                // ── Portfolio & Business ──────────────────────────────────
                _SectionLabel('Portfolio & Business'),
                _MenuGroup([
                  _MenuItem(LucideIcons.image,       'Portfolio',  'Photos, videos and past work',   () => context.push('/service-provider/portfolio')),
                  _MenuItem(LucideIcons.package,     'Packages',   'Manage pricing and packages',     () => context.push('/service-provider/packages')),
                  _MenuItem(LucideIcons.star,        'Reviews',    'Client feedback and ratings',     () => context.push('/service-provider/reviews')),
                ]),"""

new_menu = """                // ── Portfolio & Business ──────────────────────────────────
                _SectionLabel('Portfolio & Business'),
                _MenuGroup([
                  _MenuItem(LucideIcons.image,       'Portfolio',  'Photos, videos and past work',   () => context.push('/service-provider/portfolio')),
                  _MenuItem(LucideIcons.package,     'Packages',   'Manage pricing and packages',     () => context.push('/service-provider/packages')),
                  if (sp.venueType.isNotEmpty || sp.capacity > 0)
                    _MenuItem(LucideIcons.layoutGrid,  'Seating Layout', 'Define physical seating areas', () => context.push('/service-provider/seating')),
                  _MenuItem(LucideIcons.star,        'Reviews',    'Client feedback and ratings',     () => context.push('/service-provider/reviews')),
                ]),"""

content = content.replace(old_menu, new_menu)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated profile menu")
