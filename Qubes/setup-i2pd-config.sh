#!/bin/bash

# Script: modify_i2pd_conf.sh
# Purpose: Safely modify i2pd.conf for Qubes Whonix-Gateway ProxyVMs
# Features: IP validation, port configuration, backup with timestamp, error handling

CONFIG_FILE="i2pd.conf"

# 1. Validate that the config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found in the current directory."
    exit 1
fi

# 2. Prompt for and validate the Qubes Whonix-Gateway IP Address
while true; do
    read -rp "Enter Qubes Whonix-Gateway IP Address: " IPADDR
    if [[ $IPADDR =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Check each octet is <= 255
        VALID=1
        IFS='.' read -ra OCTETS <<< "$IPADDR"
        for OCTET in "${OCTETS[@]}"; do
            if (( OCTET < 0 || OCTET > 255 )); then
                VALID=0
                break
            fi
        done
        if (( VALID )); then
            break
        fi
    fi
    echo "Invalid IP address. Please enter a valid IPv4 address (e.g., 10.137.0.1)."
done

# 3. Prompt for and validate the Global Port Number
while true; do
    read -rp "Enter Global Port Number (1-65535): " PORT
    if [[ $PORT =~ ^[0-9]+$ ]] && (( PORT >= 1 && PORT <= 65535 )); then
        break
    fi
    echo "Invalid port number. Please enter a value between 1 and 65535."
done

# 4. Create a timestamped backup
TIMESTAMP=$(date +"%Y%m%d%H%M%S")
BACKUP_FILE="i2pd.conf.original-$TIMESTAMP"
cp "$CONFIG_FILE" "$BACKUP_FILE"
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create backup file."
    exit 1
fi
echo "Backup created: $BACKUP_FILE"

# 5. Replace all instances of 127.0.0.1 with the provided IP address
sed -i "s/127\.0\.0\.1/$IPADDR/g" "$CONFIG_FILE"

# 6. Uncomment and set the 'Port to listen for connections' line
#    (Assumes the line is '# port = 4567' and is unique in the relevant section)
sed -i "/^# port = [0-9]\{1,5\}$/{
    s/^# //
    s/ = .*/ = $PORT/
}" "$CONFIG_FILE"

echo "All instances of 127.0.0.1 replaced with $IPADDR."
echo "'Global Port to listen for connections' set to $PORT."
echo "Modification complete."
