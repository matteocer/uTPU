from uart_driver import UARTDriver
from program_loader import ProgramLoader
from isa_encoder import encodeStoreValues


def parse_values(raw: str):
    if not raw:
        return []
    values = []
    for item in raw.split(","):
        item = item.strip()
        if not item:
            continue
        values.append(int(item, 0))
    return values


def main():
    import argparse
    import time

    parser = argparse.ArgumentParser(description="Store int4 values then fetch them back (no reset).")
    parser.add_argument("--port", "-p", required=True, help="Serial port, e.g. /dev/ttyUSB1")
    parser.add_argument("--addr", "-a", type=lambda x: int(x, 0), default=0x000, help="Base address (hex or dec)")
    parser.add_argument(
        "--values",
        "-V",
        default="1,2,3,4",
        help="Comma-separated int4 values to store (e.g. 1,2,3,4 or -1,0,7,-8)",
    )
    parser.add_argument("--count", "-c", type=int, default=None, help="How many values to fetch back")
    parser.add_argument("--verbose", "-v", action="store_true")
    args = parser.parse_args()

    values = parse_values(args.values)
    if not values:
        raise SystemExit("No values provided")

    uart = UARTDriver(args.port, baud=115200)
    loader = ProgramLoader(uart, verbose=args.verbose)

    # Clear any residual bytes (self-test, previous runs)
    uart.flush_input()

    # Build a store program (no reset / no halt)
    program = b""
    addr = args.addr
    for i in range(0, len(values), 4):
        chunk = values[i:i + 4]
        while len(chunk) < 4:
            chunk.append(0)
        program += encodeStoreValues(addr, chunk)
        addr += 1

    uart.flush_input()
    loader.sendProgram(program)
    time.sleep(0.02)

    # Drain and display any bytes returned during STORE (e.g., debug ACK)
    waiting = uart.bytes_waiting()
    if waiting:
        store_resp = uart.receive_bytes(waiting)
        print(f"Store response ({waiting} bytes): {store_resp.hex()}")
    else:
        print("Store response: (none)")

    count = args.count if args.count is not None else len(values)
    print(f"Fetching {count} values from 0x{args.addr:03X}...")
    results = loader.readResults(args.addr, count)
    print("Results:", results)

    uart.close()


if __name__ == "__main__":
    main()
