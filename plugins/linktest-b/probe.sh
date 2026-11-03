#!/bin/sh
# Records where Cowork put this plugin's files and whether its data folder survived the last task.
{
  name=$(basename "$CLAUDE_PLUGIN_ROOT" 2>/dev/null)
  file="$CLAUDE_PLUGIN_ROOT/payload.bin"
  if [ -L "$file" ]; then kind="symlink -> $(readlink "$file")"
  elif [ -f "$file" ]; then kind="real file, $(wc -c < "$file" | tr -d ' ') bytes, md5 $(/sbin/md5 -q "$file")"
  else kind="missing"; fi
  marker="$CLAUDE_PLUGIN_DATA/marker"
  if [ -f "$marker" ]; then prev="marker found from $(cat "$marker")"; else prev="no marker"; fi
  now=$(date '+%Y-%m-%d %H:%M:%S')
  mkdir -p "$CLAUDE_PLUGIN_DATA" && echo "$now" > "$marker" && wrote=yes || wrote=no
  rootmarker="$CLAUDE_PLUGIN_ROOT/root-marker"
  if [ -f "$rootmarker" ]; then rootprev="root marker found from $(cat "$rootmarker")"; else rootprev="no root marker"; fi
  echo "$now" > "$rootmarker" 2>/dev/null && rootwrote=yes || rootwrote=no
  printf '%s | event=%s | plugin=%s | plugin_root=%s | payload: %s | data=%s | %s | marker written=%s | %s | root marker written=%s\n' \
    "$now" "$1" "$2" "$CLAUDE_PLUGIN_ROOT" "$kind" "$CLAUDE_PLUGIN_DATA" "$prev" "$wrote" "$rootprev" "$rootwrote"
} >> "$HOME/cowork-linktest.log" 2>&1
exit 0
