#!/bin/bash

# Define the domains array
domains=(
	"launchdarkly.com"
	"mobile.launchdarkly.com"
	"clientstream.launchdarkly.com"
	"segment.io"
	"api.segment.io"
	"sentry.io"
	"*.ingest.sentry.io"
	"segment.com"
	"cdn-settings.segment.com"
)

# "0298668.ingest.sentry.io" for now 
# Define color codes and messages
red="\033[31m"
green="\033[32m"
reset="\033[0m"
blocked_msg="${green}✅ Blocking domain:${reset}"
unblocked_msg="${green}✅ Unblocking domain:${reset}"
not_blocked_msg="${red}❌ Domains are not currently blocked.${reset}"
already_blocked_msg="${red}❌ Domains are already blocked.${reset}"

block_domains() {
	if [ -f /etc/hosts.backup ]; then
		echo -e "$already_blocked_msg"
		return
	fi

	sudo cp /etc/hosts /etc/hosts.backup

	for domain in "${domains[@]}"; do
		echo -e "$blocked_msg $domain"
		echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null
	done

	echo -e "${green}All domains are now blocked.${reset}"
	echo "To unblock these domains, run: $0 unblock"
}

unblock_domains() {
	if [ -f /etc/hosts.backup ]; then
		echo -e "$unblocked_msg"
		sudo mv /etc/hosts.backup /etc/hosts
		for domain in "${domains[@]}"; do
			echo -e "$unblocked_msg $domain"
		done
		echo "To block these domains again, run: $0 block"
	else
		echo -e "$not_blocked_msg"
	fi
}

if [ "$1" == "block" ]; then
	block_domains
elif [ "$1" == "unblock" ]; then
	unblock_domains
else
	echo "Usage: $0 [block|unblock]"
fi
