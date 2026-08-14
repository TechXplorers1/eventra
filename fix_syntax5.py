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

        # Fix triple paren: push('/path'))), -> push('/path')),
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

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            fixed_files.append(file)
            print(f'Fixed triple-paren in: {file}')

print(f'Done. Fixed {len(fixed_files)} files.')
print()

# Report remaining ))), issues
print("Remaining ))), issues:")
for root, _, files in os.walk(dir_path):
    for file in files:
        if not file.endswith('.dart'):
            continue
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            if "context.push(" in line and ")))" in line:
                print(f"  {file}:{i+1}: {line.rstrip()[:120]}")

# Report missing ) issues - _MenuItem lines ending with push('/path'),  
print()
print("Lines with _MenuItem missing closing paren:")
for root, _, files in os.walk(dir_path):
    for file in files:
        if not file.endswith('.dart'):
            continue
        filepath = os.path.join(root, file)
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        for i, line in enumerate(lines):
            stripped = line.rstrip()
            if re.search(r"_MenuItem\(|_MenuTile\(|_NavBtn\(|_NavItem\(", line):
                if stripped.endswith("context.push('/notifications'),") or \
                   stripped.endswith("context.push('/settings'),") or \
                   stripped.endswith("context.push('/payment-methods'),") or \
                   stripped.endswith("context.push('/help'),") or \
                   stripped.endswith("context.push('/tickets'),") or \
                   stripped.endswith("context.push('/organizer'),") or \
                   stripped.endswith("context.push('/service-provider'),"):
                    print(f"  {file}:{i+1}: {stripped[:120]}")
