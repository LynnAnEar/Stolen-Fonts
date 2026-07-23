#!/system/bin/sh
MANUFACTER=$(getprop ro.product.manufacturer)
STANDARD_FOLDER="$MODPATH"/system/fonts
STATUS=0

# Font selections - corresponds to menu options
declare_fonts() {
	case $1 in
	1)
		FONT_NAME="Fredoka"
		FONT_NAME_ITALIC="NotoSans-Italic"
		MONO_FONT_NAME="NotoSansMono-Regular"
		DISPLAY_NAME="Fredoka"
		;;
	esac
}

check_font_exists() {
	if [ ! -f "$MODPATH/common/fonts/${1}.ttf" ]; then
		ui_print "  ERROR: Font file not found: ${1}.ttf"
		return 1
	fi
	return 0
}

install_font() {
	STANDARD_FONT_NAME="Roboto-Regular.ttf"
	ui_print "    Installing $DISPLAY_NAME..."
	
	# Copy fonts from common/fonts to system/fonts
	cp_ch "$MODPATH/common/fonts/${FONT_NAME}.ttf" $STANDARD_FOLDER/"$STANDARD_FONT_NAME"

	if [ $API -ge 31 ]; then
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoStatic-Regular.ttf
	else
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-Thin.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-Light.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-Medium.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-Bold.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-Black.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-Thin.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-Light.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-Medium.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-Bold.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-Black.ttf
		STANDARD_FONT_NAME="Roboto-Italic.ttf"
		cp_ch "$MODPATH/common/fonts/${FONT_NAME_ITALIC}.ttf" $STANDARD_FOLDER/"$STANDARD_FONT_NAME"
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-ThinItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-LightItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-MediumItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-BoldItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Roboto-BlackItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-ThinItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-LightItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-MediumItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-BoldItalic.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoCondensed-BlackItalic.ttf
	fi
}

install_clock_font() {
	STANDARD_FONT_NAME="Roboto-Regular.ttf"
	ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/AndroidClock.ttf

	if [ "$MANUFACTER" = "Samsung" ]; then
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/SECNum-3L.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/SECNum-3R.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2019L-RM.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2021.ttf
		ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2021_Fixed.ttf
		if [ $API -lt 31 ]; then
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2016.ttf
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2017L.ttf
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2017R.ttf
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/Clock2019L.ttf
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoNum-3L.ttf
			ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/RobotoNum-3R.ttf
		fi
	fi
	ui_print "    Clock fonts updated!"
}

install_mono_font() {
	STANDARD_FONT_NAME="DroidSansMono.ttf"
	ui_print "    Installing monospace font..."
	cp_ch "$MODPATH/common/fonts/${MONO_FONT_NAME}.ttf" $STANDARD_FOLDER/"$STANDARD_FONT_NAME"

	ln -s ./"$STANDARD_FONT_NAME" $STANDARD_FOLDER/CutiveMono.ttf
	ui_print "    Monospace font installed!"
}

clean_up() {
	rm -rf $STANDARD_FOLDER/placeholder
}

# ============================================
# FONT SELECTION MENU
# ============================================

ui_print ""
ui_print "========================================"
ui_print "    Font Selection"
ui_print "========================================"
ui_print ""
ui_print "  Press Vol+ to cycle through options"
ui_print "  Press Vol- to select"
ui_print ""
ui_print "  Available fonts:"
ui_print "  1. Noto Sans"
ui_print "  2. Open Sans"
ui_print "  3. Roboto"
ui_print "  4. Figtree"
ui_print "  5. Maple Mono"
ui_print "  6. Atkinson Hyperlegible"
ui_print ""

CHOICE=1

# Volume key selector - cycle through options
while true; do
	ui_print "  Current selection: $CHOICE"
	if chooseport 5; then
		# Vol+ pressed - next option
		CHOICE=$((CHOICE + 1))
		if [ $CHOICE -gt 6 ]; then
			CHOICE=1
		fi
	else
		# Vol- pressed - confirm selection
		break
	fi
done

ui_print ""
ui_print "  Installing selected font..."
ui_print ""

# Load font variables
declare_fonts $CHOICE

# Check if font files exist
check_font_exists "$FONT_NAME" || abort "Font file missing!"
check_font_exists "$FONT_NAME_ITALIC" || abort "Font file missing!"

# Install system font
install_font
install_clock_font
ui_print ""
ui_print "  ✓ System font installed!"
ui_print ""

# Ask about monospace
ui_print "- Install monospace font?"
ui_print "  [Vol+ = yes, Vol- = no]"
if chooseport 30; then
	check_font_exists "$MONO_FONT_NAME" || abort "Monospace font file missing!"
	install_mono_font
else
	ui_print "  Monospace font skipped"
fi

ui_print ""
ui_print "========================================"
ui_print "  Installation Complete!"
ui_print "========================================"
ui_print ""

clean_up
