import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_onboarding_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('const Divider(color: AppColors.border),', 'Divider(color: AppColors.border),')
content = content.replace('const Divider(color: AppColors.border, height: 40),', 'Divider(color: AppColors.border, height: 40),')
content = content.replace('.withOpacity(', '.withValues(alpha: ')

if 'if (context.canPop()) context.pop();' in content:
    content = content.replace('if (context.canPop()) context.pop();\n            else Future.microtask(() => context.go(\'/\'));', 'if (context.canPop()) {\n              context.pop();\n            } else {\n              Future.microtask(() => context.go(\'/\'));\n            }')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Syntax issues fixed.")
