#!/bin/bash

export DISPLAY=:0
export XAUTHORITY=/home/user/.Xauthority

xrandr -v >/dev/null

function VGA_connected {
		line_number=$(xrandr | grep -n "$VGA_name connected" | cut -f 1 -d ":")
		max_resolution_VGA1=$(xrandr | sed -n $(("$line_number"+1))p | awk '{print $1}')
		max_height_VGA1=$(echo "$max_resolution_VGA1" | cut -f 2 -d "x")
		max_width_VGA1=$(echo "$max_resolution_VGA1" | cut -f 1 -d "x")
		if [[ "$max_height_VGA1" -lt "$max_height_LVDS1" ]] || [[ "$max_width_VGA1" -lt "$max_width_LVDS1" ]]
		then
			if xrandr --output $VGA_name --mode "$max_resolution_VGA1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_VGA1" --pos 0x0 2>/dev/null
			then
				xrandr --output $VGA_name --mode "$max_resolution_VGA1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_VGA1" --pos 0x0
			else 
				find_common_mode
				xrandr --output $VGA_name --mode "$common_mode" --pos 0x0 --output $internal_screen_name --mode "$common_mode" --pos 0x0
			fi

		else
			if xrandr --output $VGA_name --mode "$max_resolution_LVDS1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_LVDS1" 2>/dev/null
			then
				xrandr --output $VGA_name --mode "$max_resolution_LVDS1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_LVDS1"
			else
				find_common_mode
				xrandr --output $VGA_name --mode "$common_mode" --pos 0x0 --output $internal_screen_name --mode "$common_mode"
			fi

		fi
}

function HDMI_connected {
		line_number=$(xrandr | grep -n "$HDMI_name connected" | cut -f 1 -d ":")
		max_resolution_HDMI1=$(xrandr | sed -n $(("$line_number"+1))p | awk '{print $1}')
		max_height_HDMI1=$(echo "$max_resolution_HDMI1" | cut -f 2 -d "x")
		max_width_HDMI1=$(echo "$max_resolution_HDMI1" | cut -f 1 -d "x")
		if [[ "$max_height_HDMI1" -lt "$max_height_LVDS1" ]] || [[ "$max_width_HDMI1" -lt "$max_width_LVDS1" ]]
		then
			if xrandr --output $HDMI_name --mode "$max_resolution_HDMI1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_HDMI1" --pos 0x0 2>/dev/null
			then
				xrandr --output $HDMI_name --mode "$max_resolution_HDMI1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_HDMI1" --pos 0x0
			else
				find_common_mode
				xrandr --output $HDMI_name --mode "$common_mode" --pos 0x0 --output $internal_screen_name --mode "$common_mode" --pos 0x0
			fi
		else
			if xrandr --output $HDMI_name --mode "$max_resolution_LVDS1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_LVDS1" 2>/dev/null
			then
				xrandr --output $HDMI_name --mode "$max_resolution_LVDS1" --pos 0x0 --output $internal_screen_name --mode "$max_resolution_LVDS1"
			else
				find_common_mode
				xrandr --output $HDMI_name --mode "$common_mode" --pos 0x0 --output $internal_screen_name --mode "$common_mode"
			fi
		fi
}

function find_common_mode {
	modes_lines=$(xrandr | grep -n -v "connected" | grep -v "Screen" | cut -f 1 -d ":")
	counter1=0
	for i in $modes_lines
		do modes_lines_array["$counter1"]="$i"
		counter1=$(( "$counter1" + 1 ))
	done
	i=0
	while [[ $(( ${modes_lines_array["$i"]} + 1 )) -eq ${modes_lines_array[$(( "$i" + 1 ))]} ]]
		do modes_LVDS1[$i]=$(xrandr | sed -n ${modes_lines_array["$i"]}p | awk '{print $1}')
		(( i++ ))
	done
	modes_LVDS1[$i]=$(xrandr | sed -n ${modes_lines_array["$i"]}p | awk '{print $1}')
	i2=0
	while [[ "$i" -le "$counter1" ]]
		do modes_external_display["$i2"]=$(xrandr | sed -n ${modes_lines_array["$i"]}p | awk '{print $1}')
		(( i2++ ))
		(( i++ ))	
	done
	i2=0
	for i in "${modes_LVDS1[@]}"
		do for i3 in "${modes_external_display[@]}"
			do if [[ "$i" == "$i3" ]]
				then common_modes["$i2"]="$i"
				(( i2++ ))
				fi
		done
	done
	IFS=$'\n' common_mode=$(sort -nr <<< ${common_modes[*]} | sed -n 1p)
	unset IFS
}

function screen_connected {

for i in $connected_displays
do
	if [[ "$i" = "$VGA_name" ]]
	then
		VGA_connected
	elif [[ "$i" = "$HDMI_name" ]]
	then
		HDMI_connected
	fi
done
}

function screen_disconnected {
xrandr --output $internal_screen_name --preferred
}

HDMI_name=$(xrandr | grep HDMI | cut -f 1 -d " ")
VGA_name=$(xrandr | grep VGA | cut -f 1 -d " ")
internal_screen_name=$(xrandr | grep LVDS | cut -f 1 -d " ")
current_resolution_LVDS1=$(xrandr | grep "Screen 0" | awk '{print $8, $9, $10}' | sed -e 's/ //g' -e 's/,//')
current_resolutions=$(xrandr | grep "*" | awk '{print $1}')
connected_displays=$(xrandr | grep -w "connected" | awk '{print $1}')
max_resolution_LVDS1=$(xrandr | sed -n $(($(xrandr | grep -n "$internal_screen_name connected" | cut -f 1 -d ":")+1))p | awk '{print $1}')
max_height_LVDS1=$(echo "$max_resolution_LVDS1" | cut -f 2 -d "x")
max_width_LVDS1=$(echo "$max_resolution_LVDS1" | cut -f 1 -d "x")
if [[ $(xrandr | grep -w "connected" | wc -l) -eq 1 ]] 
then
	screen_disconnected
else
	screen_connected
fi
