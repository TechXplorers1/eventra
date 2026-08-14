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

        # Fix pattern 1: _MenuItem/similar calls where closing ) is missing before ,
        # Example bad:  _MenuItem(args, () => context.push('/path'),
        # Example bad:  _IconBtn(icon: X, onTap: () => context.push('/path')),  <- extra )
        # 
        # The issue is that these calls were changed from:
        #   _MenuItem(args, () => context.push('/path')),
        # to (by microtask script):
        #   _MenuItem(args, () => Future.microtask(() => context.push('/path'))),
        # and back (by revert script) to:
        #   _MenuItem(args, () => context.push('/path')),  <- missing closing ) for _MenuItem
        # OR extra ) from the IconBtn pattern

        # Pattern A: Missing closing ) for widget constructors - 
        # e.g., _MenuItem(A, B, C, () => context.push('/x'),  <- missing last )
        # These appear as: context.push('something'), on a line that starts a new widget call
        # Fix: change trailing , at end of context.push call (without closing widget)) to ),
        new_content = re.sub(
            r"((?:_MenuItem|_MenuTile|_NavItem|_StatCard)\([^)]*\(\) => context\.push\('[^']*'\)),\n",
            r"\1),\n",
            new_content
        )

        # Pattern B: _IconBtn with extra ) 
        # e.g. _IconBtn(icon: X, onTap: () => context.push('/path'))),  <- extra )
        new_content = re.sub(
            r"(_IconBtn\([^)]+\(\) => context\.push\('[^']*'\))\)\),",
            r"\1),",
            new_content
        )

        # Pattern C: Simpler - any line that ends with )),  where the push is on the same line
        # and the widget call doesn't need two closing parens
        # e.g., onTap: () => context.push('/path')),  <- bad
        new_content = re.sub(
            r"(onTap: \(\) => context\.push\('[^']*'\))\),",
            r"\1,",
            new_content
        )
        new_content = re.sub(
            r"(onTap: \(\) => context\.push\(\"[^\"]*\"\))\),",
            r"\1,",
            new_content
        )

        # Pattern D: interpolated strings like '/event/${event.id}'
        # These use template-like strings - handle separately 
        # onTap: () => context.push('/event/${event.id}')), -> onTap: () => context.push('/event/${event.id}'),
        # Already handled by fix_syntax.py but double check

        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            fixed_files.append(file)
            print(f'Fixed: {file}')

print(f'\nDone. Fixed {len(fixed_files)} files.')
