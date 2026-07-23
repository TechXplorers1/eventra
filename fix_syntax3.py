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

            # Fix any line that has context.push('...') followed by extra ))
            # Pattern: context.push('something')),  -> context.push('something')),
            # We need to find lines where there are TWO closing parens after the push string
            
            # Match: ) followed by )), at end of statement (with optional whitespace before comma)
            # i.e. context.push('path')), -> context.push('path')),
            
            # More specifically the broken pattern is:
            # _SomeWidget(...args..., () => context.push('/path'),   <- missing closing ) for widget
            # OR
            # _SomeWidget(..., () => context.push('/path'))),   <- extra ) 
            
            # Check for the extra ) pattern: push('...')),
            if re.search(r"context\.push\('[^']*'\)\),", new_line):
                new_line = re.sub(r"(context\.push\('[^']*'\))\),", r"\1,", new_line)
            
            # Also fix interpolated string patterns ending in ')),
            if "context.push(" in new_line and "))" in new_line:
                # Count parens after push( to see if there's an extra one
                # Find the push( position
                m = re.search(r"context\.push\(", new_line)
                if m:
                    start = m.end()
                    # Count parens from the push(
                    depth = 1
                    pos = start
                    while pos < len(new_line) and depth > 0:
                        if new_line[pos] == '(':
                            depth += 1
                        elif new_line[pos] == ')':
                            depth -= 1
                        pos += 1
                    # pos is now right after the closing ) of push()
                    # Check if there are extra ) immediately after
                    rest = new_line[pos:]
                    # rest should start with ); or ), or ,  or spaces then those
                    # If it starts with ), that's an extra )
                    rest_stripped = rest.lstrip()
                    if rest_stripped.startswith('),'):
                        # Remove the extra )
                        new_line = new_line[:pos] + rest.replace('),', ',', 1)
                    elif rest_stripped.startswith(');'):
                        new_line = new_line[:pos] + rest.replace(');', ';', 1)

            if new_line != line:
                changed = True
                
            new_lines.append(new_line)

        if changed:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            fixed_files.append(file)
            print(f'Fixed: {file}')

print(f'\nDone. Fixed {len(fixed_files)} files.')
