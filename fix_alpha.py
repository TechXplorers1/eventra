import os
import re

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_calendar_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# I blindly replaced .withOpacity( with .withAlpha( earlier. I'll revert .withAlpha(0.xx) back to .withOpacity(0.xx)
content = re.sub(r'\.withAlpha\((0\.\d+)\)', r'.withOpacity(\1)', content)

# I should also fix `.withAlpha(25)` which should be `.withAlpha(25)` (that is valid since 25 is int).
# Wait, gig tile had `.withAlpha(25)` in the new text. Let's make sure it stays.

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed withAlpha types")
