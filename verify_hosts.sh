#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <hosts_file>"
    exit 1
fi

HOSTS_FILE="$1"

if [ ! -f "$HOSTS_FILE" ]; then
    echo "Error: File '$HOSTS_FILE' does not exist."
    exit 1
fi

verify-IP() {
    local host_name="$1"
    local file_ip="$2"

    local dns_ips
    dns_ips=$(nslookup "$host_name" 2>/dev/null | awk '/^Name:/ {found=1} found && /^Address:/ {print $2}')

    if [[ -z "$dns_ips" ]]; then
        echo "Error: Could not resolve $host_name via nslookup."
        return 2
    fi

    for ip in $dns_ips; do
        if [[ "$ip" == "$file_ip" ]]; then
            return 0
        fi
    done

    echo "Bogus IP for $host_name in $HOSTS_FILE !"
    return 1
}

while read -r ip name aliases; do
    if [[ -z "$ip" || "$ip" == \#* || "$ip" == 127.* || "$ip" == *:* ]]; then
        continue
    fi

    verify-IP "$name" "$ip"
done < "$HOSTS_FILE"
