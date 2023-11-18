#!/bin/bash

# Constants
ARC_TEL_URL="https://raw.githubusercontent.com/SenpaiHunters/ArcAdvanced/main/ArcTelemetryBlocking/ArcTel.sh"
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/etc/hosts.backup"

# Domains to be blocked/unblocked
domains=(
	"launchdarkly.com"
	"mobile.launchdarkly.com"
	"clientstream.launchdarkly.com"
	"segment.io"
	"api.segment.io"
	"sentry.io"
	"0298668.ingest.sentry.io"
	"segment.com"
	"cdn-settings.segment.com"
)

# Colors for console output
red="\033[91m" # Red
white="\033[97m" # White
green="\033[92m" # Green
blue="\033[94m" # Blue
reset="\033[0m"

# Function to display an error message and exit the script
error() {
	printf "${red}Error: $1${reset}\n" 1>&2
	exit 1
}

# Function to create a backup of the hosts file
create_backup() {
	if [ -f "$BACKUP_FILE" ]; then
		error "Backup file $BACKUP_FILE already exists."
	fi

	if ! sudo cp "$HOSTS_FILE" "$BACKUP_FILE"; then
		error "Failed to create a backup of $HOSTS_FILE."
	fi
}

# Function to flush the DNS cache and restart mDNSResponder
flush_dns() {
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
}

# Function to log domain operations
log_domain_operation() {
  printf "${green}✅ $1 domain: ${white}$2${reset}\n"
}

# Function to block the domains
block_domains() {
  if [ -f "$BACKUP_FILE" ]; then
    error "Domains are already blocked."
    return
  fi

  create_backup

  for domain in "${domains[@]}"; do
    log_domain_operation "Blocking" "$domain"
    if ! echo "127.0.0.1 $domain" | sudo tee -a "$HOSTS_FILE" >/dev/null; then
      error "Failed to add $domain to $HOSTS_FILE."
    fi
  done

  printf "${green}All domains are now blocked.${reset}\n"
  printf "To unblock these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s unblock${reset}\n"

  flush_dns
}

# Function to unblock the domains
unblock_domains() {
	if [ -f "$BACKUP_FILE" ]; then
		for domain in "${domains[@]}"; do
			sudo sed -i '' -e "/$domain/d" "$HOSTS_FILE" || error "Failed to unblock domains in $HOSTS_FILE."
		done
		sudo mv "$BACKUP_FILE" "$HOSTS_FILE" || error "Failed to restore $HOSTS_FILE from backup"

		for domain in "${domains[@]}"; do
			log_domain_operation "Unblocking" "$domain"
		done

		printf "All domains are now unblocked.\n"
		printf "To block these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s block${reset}\n"

		flush_dns
	else
		printf "${red}❌ Domains are not currently blocked.${reset}\n"
		printf "To block these domains, run:\n${blue}curl -s -L ${ARC_TEL_URL} | bash -s block${reset}\n"
	fi
}

# Function to check if the domains are blocked
check_domains() {
  for domain in "${domains[@]}"; do
    printf "Checking domain: $domain... "
    if ping -c 1 $domain &>/dev/null; then
      printf "Blocked\n"
    else
      printf "Not Blocked\n"
    fi
  done
}

# Input validation
case "$1" in
  "block") block_domains ;;
  "unblock") unblock_domains ;;
  "check") check_domains ;;
  *) error "Invalid argument. Use 'block', 'unblock', or 'check'." ;;
esac