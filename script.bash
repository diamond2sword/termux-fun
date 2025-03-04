#!/bin/bash
passphrase=$(cat "$HOME/ssh-key-passphrase.txt")
email="diamond2sword@gmail.com"
system="ed25519"

gh auth logout

gh auth login -p ssh --skip-ssh-key -w -s read:gpg_key,admin:public_key,admin:ssh_signing_key,repo || exit 1

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

cat "$key_path.pub"

gh ssh-key add "$key_path.pub" -t "termux"

delete_ssh_keys_except_last()
{
	list=$(gh ssh-key list)
	echo "$list" |
	grep -v "$(echo "$list" | awk '{print $4}' | sort | tail -n 1)" |
	awk '{print $5}' | xargs -I {} gh ssh-key delete {} --yes
}
delete_ssh_keys_except_last
