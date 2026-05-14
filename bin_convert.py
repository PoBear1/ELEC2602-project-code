#!/usr/bin/env python3
import sys

def convert(input_path, output_path):
    with open(input_path, 'r') as f:
        bits = [c for c in f.read() if c in '01']

    if len(bits) % 8 != 0:
        print(f"Warning: {len(bits)} bits is not a multiple of 8, padding with zeros")
        bits += ['0'] * (8 - len(bits) % 8)

    data = bytes(int(''.join(bits[i:i+8]), 2) for i in range(0, len(bits), 8))

    with open(output_path, 'wb') as f:
        f.write(data)

    print(f"Wrote {len(data)} bytes to {output_path}")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.txt> <output.bin>")
        sys.exit(1)
    convert(sys.argv[1], sys.argv[2])
