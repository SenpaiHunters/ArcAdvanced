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

    success=true

    for domain in "${domains[@]}"; do
        echo "Blocking $domain..."
        echo "127.0.0.1 $domain" | sudo tee -a /etc/hosts >/dev/null

        if ping -c 1 $domain | grep -q "PING $domain (127.0.0.1)"; then
            echo -e "\\033[32m✅ $domain – Blocked Successfully\\033[0m"
        else
            echo -e "\\033[31m❌ $domain – Not Blocked\\033[0m"
            success=false
        fi
    done

    if $success; then
        echo "All domains blocked successfully."
    else
        echo "Some domains failed to block."
    fi
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

    success=true

    for domain in "${domains[@]}"; do
        echo "Unblocking $domain..."
        sudo sed -i '' "/$domain/d" /etc/hosts

        if ! ping -c 1 $domain | grep -q "PING $domain (127.0.0.1)"; then
            echo -e "\\033[32m✅ $domain – Unblocked Successfully\\033[0m"
        else
            echo -e "\\033[31m❌ $domain – Not Unblocked\\033[0m"
            success=false
        fi
    done

    if $success; then
        echo "All domains unblocked successfully."
    else
        echo "Some domains failed to unblock."
    fi
}

if [ "$1" == "block" ]; then
    block_domains
elif [ "$1" == "unblock" ]; then
    unblock_domains
else
    echo "Usage: $0 [block|unblock]"
fi
