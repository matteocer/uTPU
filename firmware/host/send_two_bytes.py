import argparse

from uart_driver import UARTDriver


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Send two bytes over UART to the FPGA."
    )
    parser.add_argument(
        "--port",
        default="/dev/ttyUSB1",
        help="Serial port device (default: /dev/ttyUSB1)",
    )
    parser.add_argument(
        "--baud",
        type=int,
        default=115200,
        help="UART baud rate (default: 115200)",
    )
    parser.add_argument(
        "--hex",
        nargs=2,
        default=["20", "00"],
        help="Two bytes as hex strings (default: 20 00)",
    )
    parser.add_argument(
        "--expect",
        type=int,
        default=2,
        help="Expected response length in bytes (default: 2)",
    )
    parser.add_argument(
        "--timeout",
        type=float,
        default=1.0,
        help="Response timeout in seconds (default: 1.0)",
    )
    parser.add_argument(
        "--wait-aa",
        action="store_true",
        help="Wait for the one-time 0xAA self-test byte before sending",
    )
    parser.add_argument(
        "--listen",
        type=float,
        default=0.0,
        help="Listen-only mode for N seconds (default: 0)",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    bytes_out = bytes(int(b, 16) for b in args.hex)

    uart = UARTDriver(args.port, baud=args.baud)
    uart.flush_input()
    if args.listen > 0:
        data = uart.receive_exact(1024, timeout=args.listen)
        if data:
            print(f"Received: {data.hex()}")
        else:
            print("No data received")
        uart.close()
        return

    if args.wait_aa:
        aa = uart.receive_exact(1, timeout=args.timeout)
        if aa == b"\xAA":
            print("Received self-test: aa")
        else:
            print("Self-test not received before timeout")

    uart.send_bytes_to_chip(bytes_out)
    print(f"Sent: {bytes_out.hex()}")

    if args.expect > 0:
        response = uart.receive_exact(args.expect, timeout=args.timeout)
        if len(response) == args.expect:
            print(f"Received: {response.hex()}")
            if response == bytes_out:
                print("Match: response equals sent bytes")
            else:
                print("Mismatch: response differs from sent bytes")
        else:
            print(f"Timeout: received {len(response)}/{args.expect} bytes")

    uart.close()


if __name__ == "__main__":
    main()
