#!/bin/bash
MAC_FILE=/etc/napi-mac
IFACE=end0

if [ ! -f "$MAC_FILE" ]; then
    BYTES=$(od -A n -t x1 -N 6 /dev/urandom | tr -d ' \n')
    B1=$(printf '%02x' $(( 0x${BYTES:0:2} & 0xfe | 0x02 )))
    MAC="${B1}:${BYTES:2:2}:${BYTES:4:2}:${BYTES:6:2}:${BYTES:8:2}:${BYTES:10:2}"
    echo "$MAC" > "$MAC_FILE"
fi

MAC=$(cat "$MAC_FILE")
ip link set "$IFACE" down
ip link set "$IFACE" address "$MAC"
ip link set "$IFACE" up
