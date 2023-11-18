#!/bin/bash

# Constants
ARC_TEL_URL="https://raw.githubusercontent.com/SenpaiHunters/ArcAdvanced/main/ArcTelemetryBlocking/ArcTel.sh"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.backup"

# Define the domains array as a regular indexed array
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

# Colors
purple="\033[94m" # Purple
red="\033[91m" # Red
white="\033[97m" # White
green="\033[92m" # Green
blue="\033[94m" # Blue
reset="\033[0m"

# Functions
error() {
	echo -e "${red}Error: $1${reset}" 1>&2
	exit 1
}

create_backup() {
	if [ -f "$BACKUP_FILE" ]; then
		error "Backup file $BACKUP_FILE already exists."
	fi

	if ! sudo cp "$HOSTS_FILE" "$BACKUP_FILE"; then
		error "Failed to create a backup of $HOSTS_FILE."
	fi
}

block_domains() {
	if [ -f "$BACKUP_FILE" ]; then
		error "Domains are already blocked."
		return
	fi

	create_backup

	for domain in "${domains[@]}"; do
		echo -e "${green}✅ Blocking domain: ${white}$domain${reset}"
		if ! echo "127.0.0.1 $domain" | sudo tee -a "$HOSTS_FILE" >/dev/null; then
			error "Failed to add $domain to $HOSTS_FILE."
		fi
	done

	echo -e "${green}All domains are now blocked.${reset}"
	echo -e "To unblock these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s unblock${reset}"

	# Flush DNS cache and restart mDNSResponder
	sudo dscacheutil -flushcache
	sudo killall -HUP mDNSResponder
}

unblock_domains() {
	if [ -f "$BACKUP_FILE" ]; then
		for domain in "${domains[@]}"; do
			sudo sed -i '' -e "/$domain/d" "$HOSTS_FILE" || error "Failed to unblock domains in $HOSTS_FILE."
		done
		sudo mv "$BACKUP_FILE" "$HOSTS_FILE" || error "Failed to restore $HOSTS_FILE from backup"

		for domain in "${domains[@]}"; do
			echo -e "${green}✅ Unblocking domain: ${white}$domain${reset}"
		done

		echo -e "All domains are now unblocked."
		echo -e "To block these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s block${reset}"

		# Flush DNS cache and restart mDNSResponder
		sudo dscacheutil -flushcache
		sudo killall -HUP mDNSResponder
	else
		echo -e "${red}❌ Domains are not currently blocked.${reset}"
		echo -e "To block these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s block${reset}"
	fi
}

# Input validation
if [ "$1" == "block" ]; then
	block_domains
elif [ "$1" == "unblock" ]; then
	unblock_domains
else
	error "Invalid argument. Use 'block' or 'unblock'."
fi
