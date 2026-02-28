#!/bin/bash

# --- 1. Configuration & Paths ---
PROJECT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$PROJECT_DIR" || exit

SYN_DIR="syn"
SIM_DIR="sim"
GEN_DIR="$SIM_DIR/gen"
TOOL_DIR="$SIM_DIR/tools"
VVP_DIR="$GEN_DIR/vvp"
VCD_DIR="$GEN_DIR/vcd"

# --- 2. Storage Settings ---
MAX_WAVES=5
timestamp=$(date +"%Y%m%d_%H%M%S")

# --- 3. Input Handling & Trimming ---
if [ -z "$1" ]; then
    echo "Usage: $0 <testbench_name>"
    exit 1
fi

# Trim path (remove sim/) and extensions (.sv, .v)
# ${1##*/} removes everything up to the last slash
# ${temp%.*} removes the last extension
raw_input="${1##*/}"
tb_module="${raw_input%.*}"

tb_file="$SIM_DIR/${tb_module}.sv"
trigger_file="$TOOL_DIR/dump_trigger.sv"

# Output file paths
vvp_out="$VVP_DIR/${tb_module}_${timestamp}.vvp"
vcd_out="$VCD_DIR/${tb_module}_${timestamp}.vcd"

# Ensure directories exist
mkdir -p "$VVP_DIR" "$VCD_DIR"

# --- 4. Validation ---
if [ ! -f "$tb_file" ]; then
    echo "Error: Testbench file not found at $tb_file"
    exit 1
fi

# --- 5. Waveform Management ---
echo "--- Cleaning old waveforms in $VCD_DIR (Target: $MAX_WAVES) ---"
old_waves=$(ls -1tr "$VCD_DIR/${tb_module}"_*.vcd 2>/dev/null | \
            head -n -$(($MAX_WAVES - 1)))

for f in $old_waves; do
    rm -f "$f"
done

# --- 6. Compilation ---
echo "--- Compiling: $tb_module ---"
iverilog -g2012 -Wall \
    -D DUMP_FILE="\"$vcd_out\"" \
    -s "$tb_module" \
    -s dump_trigger \
    -o "$vvp_out" \
    "$SYN_DIR"/*.sv \
    "$tb_file" \
    "$trigger_file"

if [ $? -eq 0 ]; then
    # --- 7. Simulation & Visualization ---
    echo "--- Running Simulation ---"
    vvp -n "$vvp_out"
    [ -f "$vcd_out" ] && surfer "$vcd_out"
else
    echo "Compilation failed!"
    exit 1
fi
