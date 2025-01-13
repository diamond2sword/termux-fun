#!/bin/bash
passphrase=$(cat "$HOME/ssh-key-passphrase.txt")
email="diamond2sword@gmail.com"
system="ed25519"

rm -rf ~/.ssh

expect << EOF
	spawn ssh-keygen -t "$system" -C "$email"
	expect {
		-re {Enter file in which to save the key} {
			send "\r"
			exp_continue
		}
		-re {empty for no passphrase} {
			send "$passphrase\r"
			exp_continue
		}
		-re {Enter same passphrase again} {
			send "$passphrase\r"
			exp_continue
		}
		-re {Enter passphrase for} {
			send "$passphrase\r"
			exp_continue
		}
		eof
	}
EOF

key_path="$HOME/.ssh/id_$system"
chmod 600 "$key_path"
eval "$(ssh-agent -s)"

expect << EOF
	spawn ssh-add "$key_path"
	expect {
		-re {Enter passphrase for} {
			send "$passphrase\r"
			exp_continue
		}
		eof
	}
EOF
