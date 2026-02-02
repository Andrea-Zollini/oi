#!/bin/bash
#
# hardware_detect.sh - System hardware detection for oi
# Detects VRAM, RAM, and CPU cores to recommend suitable models
#

get_gpu_info() {
    local vram_gb=0
    local gpu_name="None"
    local cuda_available="no"
    
    if command -v nvidia-smi &> /dev/null; then
        local vram_mb=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -n1 | tr -d ' ')
        if [ -n "$vram_mb" ] && [ "$vram_mb" != "[Insufficientpermissions]" ]; then
            vram_gb=$(echo "scale=1; $vram_mb / 1024" | bc 2>/dev/null || echo "0")
            gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1 | sed 's/^ *//;s/ *$//')
            cuda_available="yes"
        fi
    fi
    
    echo "${vram_gb}|${gpu_name}|${cuda_available}"
}

get_ram_info() {
    local ram_gb=$(free -g 2>/dev/null | awk '/^Mem:/{print $2}')
    if [ -z "$ram_gb" ] || [ "$ram_gb" = "0" ]; then
        ram_gb=$(free -m 2>/dev/null | awk '/^Mem:/{print int($2/1024)}')
    fi
    echo "${ram_gb:-0}"
}

get_cpu_info() {
    local cores=$(nproc 2>/dev/null || echo "1")
    local model=$(lscpu 2>/dev/null | grep "Model name" | cut -d':' -f2 | sed 's/^ *//' | head -n1)
    echo "${cores}|${model:-Unknown}"
}

detect_hardware() {
    local gpu_data=$(get_gpu_info)
    local vram_gb=$(echo "$gpu_data" | cut -d'|' -f1)
    local gpu_name=$(echo "$gpu_data" | cut -d'|' -f2)
    local cuda_available=$(echo "$gpu_data" | cut -d'|' -f3)
    
    local ram_gb=$(get_ram_info)
    local cpu_data=$(get_cpu_info)
    local cpu_cores=$(echo "$cpu_data" | cut -d'|' -f1)
    local cpu_model=$(echo "$cpu_data" | cut -d'|' -f2)
    
    # Calculate total available memory for models
    local total_memory_gb=$(echo "$vram_gb + $ram_gb" | bc 2>/dev/null || echo "$ram_gb")
    
    cat <<EOF
{
  "vram_gb": ${vram_gb:-0},
  "ram_gb": ${ram_gb:-0},
  "total_memory_gb": ${total_memory_gb:-0},
  "gpu_name": "${gpu_name}",
  "cuda_available": "${cuda_available}",
  "cpu_cores": ${cpu_cores:-1},
  "cpu_model": "${cpu_model}"
}
EOF
}

# If script is run directly, output hardware info
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    detect_hardware
fi
