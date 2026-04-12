import math
import argparse
from pathlib import Path

def split_urls(input_file, output_prefix, chunk_size=250):
    with open(input_file, 'r') as f:
        urls = [line.strip() for line in f if line.strip()]
    
    total_urls = len(urls)
    total_chunks = math.ceil(total_urls / chunk_size)
    
    print(f"Total URLs: {total_urls}")
    print(f"Chunk size: {chunk_size}")
    print(f"Total chunks: {total_chunks}")
    
    for i in range(total_chunks):
        start = i * chunk_size
        end = min(start + chunk_size, total_urls)  # Ensure we don't go past the end
        chunk_urls = urls[start:end]
        
        output_file = f"{output_prefix}_{i+1:02d}.txt"
        with open(output_file, 'w') as out_f:
            out_f.write('\n'.join(chunk_urls))
        
        print(f"Wrote {len(chunk_urls)} URLs to {output_file}")

def build_parser():
    parser = argparse.ArgumentParser(
        description="Split a URL list into numbered chunk files.",
    )
    parser.add_argument("input_file", help="Text file containing one URL per line")
    parser.add_argument("output_prefix", help="Prefix for numbered output files")
    parser.add_argument(
        "-n", "--chunk-size", type=int, default=250,
        help="URLs per output file (default: 250)",
    )
    return parser

if __name__ == "__main__":
    args = build_parser().parse_args()
    split_urls(Path(args.input_file), args.output_prefix, args.chunk_size)
