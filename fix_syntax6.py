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
            lines = f.readlines()

        new_lines = []
        changed = False

        for line in lines:
            new_line = line
            stripped = line.rstrip()
            
            # These lines are _MenuItem/_MenuTile/_NavBtn calls missing their final closing )
            # Pattern: the line contains a widget constructor and ends with context.push('/something'),
            # but is missing the closing ) for the widget itself
            # So we change the trailing ), to )),
            
            widget_patterns = [
                '_MenuItem(', '_MenuTile(', '_NavBtn(', '_NavItem(', '_IconBtn('
            ]
            
            has_widget = any(p in line for p in widget_patterns)
            has_push = "context.push('" in line or 'context.push("' in line
            
            if has_widget and has_push and stripped.endswith('),') and not stripped.endswith(')),'):
                # This line is a widget call that ends with push('/path'),
                # It needs an extra ) to close the widget constructor
                new_line = line.rstrip()[:-1] + '),\n'
                changed = True
            
            new_lines.append(new_line)

        if changed:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            fixed_files.append(file)
            print(f'Fixed missing ) in: {file}')

print(f'Done. Fixed {len(fixed_files)} files.')
