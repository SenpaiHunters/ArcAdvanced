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
        echo -e "\\033[32mAll domains are now blocked. Your privacy is protected!\\033[0m"
    else
        echo -e "\\033[31mSome domains failed to block. Please check your system configuration.\\033[0m"
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
        echo -e "\\033[32mAll domains are now unblocked. Your internet access is restored!\\033[0m"
    else
        echo -e "\\033[31mSome domains failed to unblock. Please check your system configuration.\\033[0m"
    fi
}

if [ "$1" == "block" ]; then
    echo "Blocking telemetry domains..."
    block_domains
elif [ "$1" == "unblock" ]; then
    echo "Unblocking telemetry domains..."
    unblock_domains
else
    echo "Usage: $0 [block|unblock]"
fi
