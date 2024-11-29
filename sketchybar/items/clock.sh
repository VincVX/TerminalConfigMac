#!/usr/bin/env bash

COLOR="$MAGENTA"

sketchybar --add item clock right \
	--set clock update_freq=1 \
	icon.padding_left=10 \
	icon.color="$BLUE" \
	icon="" \
	label.color="$BLUE" \
	label.padding_right=5 \
	label.width=78 \
	align=center \
	background.height=26 \
	background.corner_radius="$CORNER_RADIUS" \
	background.padding_right=2 \
	background.border_width="$BORDER_WIDTH" \
	background.border_color="$BLUE" \
	background.color="$BAR_COLOR" \
	background.drawing=on \
	script="$PLUGIN_DIR/clock.sh"
