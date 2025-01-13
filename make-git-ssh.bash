	#Para gumawa ng SSH key gamit ang gh (GitHub CLI), ito ang steps:

	#1. Generate SSH Key
#email="diamond2sword@gmail.com"
#rm -rf ~/.ssh
#ssh-keygen -t ed25519 -C "$email"

	#Kung wala kang Ed25519 support, puwede mong gamitin:

	#ssh-keygen -t rsa -b 4096 -C "diamond@example.com"

	#2. Add SSH Key sa SSH Agent
	#Start the agent:
chmod 600 ~/.ssh/id_ed25519
eval "$(ssh-agent -s)"

	#Add the key:

ssh-add ~/.ssh/id_ed25519


#3. Add SSH Key sa GitHub gamit ang gh
#Output the SSH key:

cat ~/.ssh/id_ed25519.pub

#Add the key to your GitHub account:

gh ssh-key add ~/.ssh/id_ed25519.pub -t "termux"

exit


#G na ‘yan! Ready ka na mag-clone o push gamit ang SSH.


