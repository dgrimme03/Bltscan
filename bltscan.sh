#!/bin/bash
# Function to convert RSSI (Received Signal Strength Indication) to approximate distance
rssi_to_distance() {
    local rssi=$1
    # The following formula is a basic approximation, and the actual relationship depends on various factors
    distance=$(echo "scale=2; 10 ^ ((27.55 - (20 * log10(2400)) + abs($rssi)) / 20)" | bc)
    echo "$distance meters"
}

# Check if the hcitool command is available
if command -v hcitool &> /dev/null; then
    # Check if Bluetooth is enabled
    if hciconfig | grep -q "UP RUNNING"; then
        # Scan for nearby Bluetooth devices
        devices=$(hcitool scan | grep -E '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})' | cut -f 2-)

        # Display the name and approximate distance for each device
        while read -r device_info; do
            mac_address=$(echo "$device_info" | cut -f 1)
            device_name=$(echo "$device_info" | cut -f 2-)
            
            # Get RSSI for the device
            rssi=$(hcitool rssi "$mac_address" | grep -oE '[-]?[0-9]+')

            # Convert RSSI to approximate distance
            distance=$(rssi_to_distance "$rssi")

            echo "Device Name: $device_name"
            echo "MAC Address: $mac_address"
            echo "Approximate Distance: $distance"
            echo "------------------------"
        done <<< "$devices"
    else
        echo "Bluetooth is not enabled. Please enable Bluetooth before running this script."
    fi
else
    echo "Error: hcitool command not found. Please install it before running this script."
fi


