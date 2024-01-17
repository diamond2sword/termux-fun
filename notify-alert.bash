# Download the sound file
curl -LJO https://github.com/user/repo/raw/main/notification.mp3
mkdir -p ~/notif
mv notification.mp3 ~/notif/notification.mp3 -f

# Create an alerting notification
termux-notification \
	--title "Alert" \
	--content "Notification message here" \
	--sound \
	--priority high \
	--action "
		termux-vibrate -d 1000
		termux-vibrate -d 500
		termux-vibrate -d 500
		termux-vibrate -d 1000
		termux-vibrate -d 1000
		termux-vibrate -d 1000
		termux-vibrate -d 1000
		termux-vibrate -d 500
		termux-vibrate -d 500
	" \
	--button1 "Echo Hello" \
	--button1-action "echo hi | termux-toast" \
	--button2 "Echo Hey" \
	--button2-action "echo hi | termux-toast" \
	--button3 "Echo They" \
	--button3-action "echo hi | termux-toast" \
	--on-delete ""
