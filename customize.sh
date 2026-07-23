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

# 3) patch system fonts.xml safely by inserting our families before </familyset>
SYS_FONTS_XML=/system/etc/fonts.xml
if [ -f "$SYS_FONTS_XML" ]; then
  ui_print "- Creating overlayed fonts.xml at $MODPATH/system/etc/fonts.xml (inserting Fredoka family)..."
  cp -f "$SYS_FONTS_XML" "$TMPDIR/orig_fonts.xml"
  OUT="$MODPATH/system/etc/fonts.xml"
  awk -v add="$(sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' "$FAM_FILE" | tr -d '\r' | sed ':a;N;$!ba;s/\n/\\n/g')" '
  {
    if ($0 ~ /<\/familyset>/ && !done) {
      split(add, a, "\\n")
      for (i=1;i<=length(a);i++) if (a[i] != "") print a[i]
      done=1
    }
    print $0
  }' "$TMPDIR/orig_fonts.xml" > "$OUT" || {
    ui_print "  ! Failed to inject into fonts.xml - copying original to overlay instead."
    cp -f "$TMPDIR/orig_fonts.xml" "$OUT"
  }
else
  ui_print "  ! /system/etc/fonts.xml not found; skipping automatic patch. Add a fonts.xml in common/my_families.xml if needed."
fi

# 4) set permissions
ui_print "- Setting permissions..."
set_perm_recursive $MODPATH/system/fonts 0 0 0755 0644
if [ -f "$MODPATH/system/etc/fonts.xml" ]; then
  set_perm $MODPATH/system/etc/fonts.xml 0 0 0644
fi

ui_print "- Fredoka install prepared. Reboot to apply fonts."
exit 0
