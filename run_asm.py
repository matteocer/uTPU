import sys
import os
import time
from typing import Optional

# Ensure we can import from firmware/host
sys.path.append(os.path.join(os.path.dirname(__file__), 'firmware/host'))

try:
    from uart_driver import UARTDriver
    from program_loader import ProgramLoader
except ImportError:
    print("Error: Could not import uTPU drivers. Make sure you are in the uTPU root directory.")
    sys.exit(1)

def run_binary(bin_path: str, port: str):
    if not os.path.exists(bin_path):
        print(f"Error: Binary file not found: {bin_path}")
        return

    print(f"Opening UART on {port}...")
    try:
        uart = UARTDriver(port, baud=115200)
        loader = ProgramLoader(uart, verbose=True)

        # 1. Reset Chip
        loader.resetChip()

        # 2. Read Binary
        print(f"Reading {bin_path}...")
        with open(bin_path, 'rb') as f:
            program_data = f.read()

        # 3. Send Binary
        # The .bin file from assembler.c is already formatted as a sequence of 16-bit instructions (Little Endian)
        # ProgramLoader.sendProgram expects a bytes object, which is exactly what we have.
        print(f"Sending {len(program_data)} bytes to FPGA...")
        loader.sendProgram(program_data)

        # 4. Wait for potential output (if the program produces any, e.g. FETCH)
        # For the demo, we expect 2 bytes (1 word) of result.
        # We'll wait a bit.
        print("Program sent. Waiting for output (if any)...")
        time.sleep(1.0) 
        
        while uart.bytes_waiting() > 0:
            byte = uart.receive_byte()
            print(f"Received byte: 0x{byte:02X}")

        uart.close()
        print("Execution complete.")

    except Exception as e:
        print(f"Execution failed: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python run_asm.py <file.bin> [COM_PORT]")
        print("Example: python run_asm.py demo_inference.bin COM3")
        sys.exit(1)

    bin_file = sys.argv[1]
    com_port = sys.argv[2] if len(sys.argv) > 2 else "COM3"

    run_binary(bin_file, com_port)
