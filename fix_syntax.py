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

        # The previous microtask wrapping script changed:
        #   onTap: () => context.push('/path'),
        # to:
        #   onTap: () => Future.microtask(() => context.push('/path')),
        # Then the revert script changed it back but left an extra ) because
        # it matched the inner push closing paren as the outer one:
        #   onTap: () => context.push('/path')),   <-- extra )
        #
        # Fix: remove the extra ) after push(...))
        # Pattern: onTap: () => context.push(ANYTHING)),  --> onTap: () => context.push(ANYTHING),

        # Fix single-quoted string args with possible interpolation
        new_content = re.sub(
            r"(onTap: \(\) => context\.push\([^)]+\))\),",
            r"\1,",
            new_content
        )

        # Fix for GestureDetector/InkWell onTap with multi-char path
        # Also handle cases where the closing )) appears at end of expression with semicolon
        new_content = re.sub(
            r"(onTap: \(\) => context\.push\([^)]+\))\);",
            r"\1;",
            new_content
        )

        # Fix similar issue in organizer_dashboard and profile screens
        # These have: onTap: () => context.push('/some/path')),
        # after the revert script didn't account for the double ))
        new_content = re.sub(
            r"(=> context\.push\('[^']*'\))\),",
            r"\1,",
            new_content
        )

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            fixed_files.append(file)
            print(f'Fixed: {file}')

print(f'\nDone. Fixed {len(fixed_files)} files.')
