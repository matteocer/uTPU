import argparse
import time

from uart_driver import UARTDriver


def main() -> int:
    parser = argparse.ArgumentParser(description="UART link smoke test for FPGA.")
    parser.add_argument("--port", "-p", required=True, help="Serial port (e.g., COM3 or /dev/ttyUSB1)")
    parser.add_argument("--baud", "-b", type=int, default=115200, help="Baud rate (default: 115200)")
    parser.add_argument("--timeout", "-t", type=float, default=1.0, help="Read timeout in seconds")
    parser.add_argument("--write-timeout", "-wt", type=float, default=1.0, help="Write timeout in seconds")
    parser.add_argument("--bytes", "-n", type=int, default=32, help="Number of bytes to send")
    parser.add_argument("--delay", "-d", type=float, default=0.05, help="Delay before reading (seconds)")
    parser.add_argument(
        "--read-window",
        "-w",
        type=float,
        default=0.5,
        help="How long to keep polling for incoming bytes (seconds)",
    )
    parser.add_argument(
        "--expect-echo",
        action="store_true",
        help="Require echoed bytes (use when FPGA design loops back or TX is wired to RX).",
    )
    args = parser.parse_args()

    # Deterministic payload
    payload = bytes([(i * 37 + 0x5A) & 0xFF for i in range(args.bytes)])

    with UARTDriver(args.port, baud=args.baud, timeout=args.timeout, write_timeout=args.write_timeout) as uart:
        uart.flush_input()
        time.sleep(0.05)  # Let FPGA settle after flush
        print(f"Sending {len(payload)} bytes...")
        uart.send_bytes_to_chip(payload)
        uart.flush_output()
        time.sleep(args.delay)

        data_chunks = []
        deadline = time.time() + args.read_window
        while time.time() < deadline:
            waiting = uart.bytes_waiting()
            if waiting:
                data_chunks.append(uart.receive_bytes(waiting))
            else:
                time.sleep(0.01)

        data = b"".join(data_chunks)
        if data:
            print(f"Received {len(data)} bytes: {data.hex()}")
        else:
            print("Received 0 bytes.")

    if args.expect_echo:
        if data == payload:
            print("PASS: echo matched payload.")
            return 0
        print("FAIL: echo did not match payload.")
        print(f"Expected: {payload.hex()}")
        return 1

    print("PASS: UART write completed. (Echo not required)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
