#!/bin/bash

block_domains() {
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

	if [ -f /etc/hosts.backup ]; then
		echo -e "\033[31m❌ Domains are already blocked.\033[0m"
		return
	fi

	echo -e "\033[32m✅ Blocking domains...\033[0m"
	sudo cp /etc/hosts /etc/hosts.backup

	for domain in "${domains[@]}"; do
		echo -e "\033[32m✅ Blocking $domain...\033[0m"
		echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null
	done

	echo -e "\033[32mAll domains are now blocked.\033[0m"
	echo "To unblock these domains, run: $0 unblock"
}

unblock_domains() {
	if [ -f /etc/hosts.backup ]; then
		echo -e "\033[32m✅ Unblocking domains...\033[0m"
		sudo mv /etc/hosts.backup /etc/hosts
		for domain in "${domains[@]}"; do
			echo -e "\033[32m✅ Unblocking $domain...\033[0m"
		done
		echo "To block these domains again, run: $0 block"
	else
		echo -e "\033[31m❌ Domains are not currently blocked.\033[0m"
	fi
}

if [ "$1" == "block" ]; then
	block_domains
elif [ "$1" == "unblock" ]; then
	unblock_domains
else
	echo "Usage: $0 [block|unblock]"
fi
