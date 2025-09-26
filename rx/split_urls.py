import sys
import math

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

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python split_urls.py input_urls.txt output_prefix")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_prefix = sys.argv[2]
    
    split_urls(input_file, output_prefix)