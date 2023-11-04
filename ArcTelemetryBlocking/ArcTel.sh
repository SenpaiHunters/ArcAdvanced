#!/bin/bash

# Define the URL
arc_tel_url="https://raw.githubusercontent.com/SenpaiHunters/ArcAdvanced/main/ArcTelemetryBlocking/ArcTel.sh"

# Define the domains array
domains=(
	"launchdarkly.com"
	"mobile.launchdarkly.com"
	"clientstream.launchdarkly.com"
	"segment.io"
	"api.segment.io"
	"sentry.io"
	"*.ingest.sentry.io"
	# "0298668.ingest.sentry.io"
	"segment.com"
	"cdn-settings.segment.com"
)

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

	if ! sudo cp /etc/hosts /etc/hosts.backup; then
		echo -e "${red}Error: Failed to create a backup of /etc/hosts.${reset}"
		exit 1
	fi

	for domain in "${domains[@]}"; do
		echo -e "$blocked_msg $domain"
		if ! echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null; then
			echo -e "${red}Error: Failed to add $domain to /etc/hosts.${reset}"
			exit 1
		fi
	done

	echo -e "${green}All domains are now blocked.${reset}"
	echo "To unblock these domains, run: curl -s -L $arc_tel_url | bash -s unblock"
}

unblock_domains() {
	if [ -f /etc/hosts.backup ]; then
		if ! sudo sed -i -e "/127.0.0.1/ d" /etc/hosts; then
			echo -e "${red}Error: Failed to unblock domains in /etc/hosts.${reset}"
			exit 1
		fi

		if ! sudo mv /etc/hosts.backup /etc/hosts; then
			echo -e "${red}Error: Failed to restore /etc/hosts from backup.${reset}"
			exit 1
		fi

		for domain in "${domains[@]}"; do
			echo -e "$unblocked_msg $domain"
		done
		echo "To block these domains, run: curl -s -L $arc_tel_url | bash -s block"
	else
		echo -e "$not_blocked_msg"
		echo "To block these domains, run: curl -s -L $arc_tel_url | bash -s block"
	fi
}

# Input validation
if [ "$1" == "block" ]; then
	block_domains
elif [ "$1" == "unblock" ]; then
	unblock_domains
fi
