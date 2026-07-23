#!/system/bin/sh
# Simple Magisk installer: installs bundled fonts (fonts/) and injects family entries.

set -e
ui_print() { echo "$@"; }

mkdir -p $MODPATH/system/fonts
mkdir -p $MODPATH/system/etc

TMPDIR=${TMPDIR:-/data/local/tmp}

# 1) extract bundled fonts/ from the zip (if present)
unzip -qjo "$ZIPFILE" 'fonts/*' -d $TMPDIR || true
if [ -d "$TMPDIR/fonts" ] && [ "$(ls -A $TMPDIR/fonts 2>/dev/null)" ]; then
  ui_print "- Copying bundled font(s)..."
  cp -a "$TMPDIR/fonts/"* "$MODPATH/system/fonts/" 2>/dev/null || true
fi

# 2) prepare family additions (common/my_families.xml)
unzip -qjo "$ZIPFILE" 'common/my_families.xml' -d $TMPDIR || true
if [ -f "$TMPDIR/my_families.xml" ]; then
  FAM_FILE="$TMPDIR/my_families.xml"
else
  cat > "$TMPDIR/my_families.xml" <<'EOF'
<family>
  <name>Fredoka</name>
  <font weight="400" style="normal">/system/fonts/Fredoka-Regular.ttf</font>
</family>
<alias name="sans-serif" to="Fredoka" />
EOF
  FAM_FILE="$TMPDIR/my_families.xml"
fi

# --- begin robust fonts.xml injection (portable) ---
# $ORIG_XML is the path to the device/system fonts.xml the script found
# $MOD_ETC is the desired overlay path inside the module (e.g. "$MODPATH/system/etc/fonts.xml")
mkdir -p "$(dirname "$MOD_ETC")"

# Create overlay by copying the first part up to </familyset>
if sed -n '1,/<\/familyset>/p' "$ORIG_XML" > "$MOD_ETC"; then
  # Append our family block
  cat >> "$MOD_ETC" <<'XML'
<!-- Inserted by Open Fonts - Fredoka -->
<family>
  <name>Fredoka</name>
  <font weight="400" style="normal">/system/fonts/Fredoka-Regular.ttf</font>
</family>
XML
  # Append the remainder of the original file (including the closing </familyset> and beyond)
  sed -n '/<\/familyset>/,$p' "$ORIG_XML" >> "$MOD_ETC"
else
  # Fallback: copy original entirely (so we still overlay)
  cp -a "$ORIG_XML" "$MOD_ETC"
fi

# set permissions
chmod 644 "$MOD_ETC" || true
chown root:root "$MOD_ETC" || true
# --- end robust injection ---

# 4) set permissions
ui_print "- Setting permissions..."
set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
if [ -f "$MODPATH/system/etc/fonts.xml" ]; then
  set_perm $MODPATH/system/etc/fonts.xml 0 0 0644
fi

ui_print "- Fredoka install prepared. Reboot to apply fonts."
exit 0
