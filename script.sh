docker build -t gem5-u22-built:riscv .
docker run -it --rm \
  -v "$HOME/Documents/sim/TP:/workspace/TP" \
  -w /workspace \
  gem5-u22-built:riscv

# Validation
gem5.opt --version