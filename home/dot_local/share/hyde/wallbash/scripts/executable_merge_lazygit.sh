#!/bin/bash
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/config.yml"
THEME="${XDG_CONFIG_HOME:-$HOME/.config}/lazygit/themes/current.yml"

[ -f "$THEME" ] || exit 0

export LG_CONFIG="$CONFIG"
THEME_BODY=$(cat "$THEME")
export LG_THEME_BODY="$THEME_BODY"

python3 << 'PYEOF'
import os, re

config = os.environ['LG_CONFIG']
theme = os.environ['LG_THEME_BODY']

with open(config) as f:
    content = f.read()

start_marker = "# HYDE_THEME_START"
end_marker = "# HYDE_THEME_END"
new_block = f"{start_marker}\n{theme}\n{end_marker}"

if start_marker in content:
    pattern = re.escape(start_marker) + r'.*?' + re.escape(end_marker)
    new_content = re.sub(pattern, new_block, content, flags=re.DOTALL)
else:
    new_content = content.rstrip() + "\n\n" + new_block + "\n"

with open(config, 'w') as f:
    f.write(new_content)
PYEOF
