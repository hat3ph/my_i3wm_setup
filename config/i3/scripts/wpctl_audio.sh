#!/bin/bash

audio_level=5
notification_interval=3000

function send_notification() {
	volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 2 | awk '{printf "%2.0f%%\n", 100 * $1}')
	#notify-send -t $notification_interval --icon=dialog-information "Audio Level $volume"
	notify-send -t $notification_interval --icon=audio-speakers "Audio Level $volume"
}

case $1 in
up)
	# increase audio level and send notification
	wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $audio_level%+
	send_notification $1
	;;
down)
	# decrease audio level and send notification
	wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ $audio_level%-
	send_notification $1
	;;
mute)
	# toggle audio to mute or unmute
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	# send audio muted notification if muted or send audio level notification if not muted
	if [[ -n $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | cut -d ' ' -f 3 | sed 's/^.//;s/.$//') ]]; then
		notify-send -t $notification_interval --icon=audio-volume-muted "Audio Muted"
	else
		send_notification up
	fi
	;;
esac
