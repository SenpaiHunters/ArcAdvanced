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

	for domain in "${domains[@]}"; do
		echo "Blocking $domain..."
		echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null
	done
}

unblock_domains() {
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

	for domain in "${domains[@]}"; do
		echo "Unblocking $domain..."
		sudo sed -i '' "/$domain/d" /etc/hosts
	done
}

if [ "$1" == "block" ]; then
	block_domains
	echo "Domains blocked successfully."
elif [ "$1" == "unblock" ]; then
	unblock_domains
	echo "Domains unblocked successfully."
else
	echo "Usage: $0 [block|unblock]"
fi
