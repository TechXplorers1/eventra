import os
import re

dir_path = r'd:\company-work\eventra\lib'

fixed_files = []

for root, _, files in os.walk(dir_path):
    for file in files:
        if not file.endswith('.dart'):
            continue
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        new_content = content

        # Fix the specific triple-paren pattern:
        # SomeWidget(..., onTap: () => context.push('/path'))),
        # There are 3 closing parens: one for push(), one for lambda, one extra
        # Should be: SomeWidget(..., onTap: () => context.push('/path')),
        
        # Pattern: push('...'))  with a third ) that shouldn't be there
        # context.push('/notifications'))), -> context.push('/notifications')),
        new_content = re.sub(
            r"(context\.push\('[^']*'\))\)\),",
            r"\1),",
            new_content
        )
        new_content = re.sub(
            r"(context\.push\('[^']*'\))\)\);",
            r"\1);",
            new_content
        )

        # Also for MenuItem pattern without closing ) on the widget itself:
        # _MenuItem(A, B, C, () => context.push('/path'),
        # needs to be: _MenuItem(A, B, C, () => context.push('/path')),
        # This is harder to fix with regex due to nested parens
        # Let's look for lines ending with push('...'), that start with _MenuItem
        new_content = re.sub(
            r"(_MenuItem\([^(]*(?:\([^)]*\)[^(]*)*\(\) => context\.push\('[^']*'\)),\n)",
            lambda m: m.group(0).replace(m.group(0).rstrip(), m.group(0).rstrip()[:-1] + '),\n').rstrip('\n') + '\n',
            new_content
        )

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            fixed_files.append(file)
            print(f'Fixed: {file}')

print(f'\nDone. Fixed {len(fixed_files)} files.')
print()

# Also report remaining issues
print("Scanning for remaining issues:")
for root, _, files in os.walk(dir_path):
    for file in files:
        if not file.endswith('.dart'):
            continue
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            if "context.push('" in line and ")))" in line:
                print(f"  {file}:{i+1}: {line.rstrip()[:120]}")
