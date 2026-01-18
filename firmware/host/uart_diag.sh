#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-/dev/ttyUSB1}"

echo "UART diagnostic for ${PORT}"
echo "Step 1: Reset line discipline / flow control"
stty -F "${PORT}" raw -echo -ixon -ixoff -crtscts
echo "OK"

echo "Step 2: Minimal write test (1 byte)"
python3 - <<PY
import serial
port = "${PORT}"
ser = serial.Serial(
    port,
    115200,
    timeout=1,
    write_timeout=1,
    xonxoff=False,
    rtscts=False,
    dsrdtr=False,
)
print("open")
ser.write(b'\\x20')
print("wrote 1 byte")
ser.close()
PY

echo "Step 3: Recent kernel messages"
dmesg | tail -n 50
