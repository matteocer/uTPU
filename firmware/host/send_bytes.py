from uart_driver import UARTDriver
from isa_encoder import encodeFetch
import time

uart = UARTDriver("/dev/ttyUSB1", baud=115200)
uart.flush_input()

# Send FETCH instruction (address 0, top half)
fetch_cmd = encodeFetch(0x000, top_half=True)
print(f"Sending FETCH: {fetch_cmd.hex()}")
uart.send_bytes_to_chip(fetch_cmd)

time.sleep(1)
waiting = uart.bytes_waiting()
print(f"Bytes waiting: {waiting}")
if waiting:
    data = uart.receive_bytes(waiting)
    print(f"Received: {data.hex()}")

uart.close()
