#!/usr/bin/env bash
# Hardware Detection Script for qalarc_OS
# Detects CPU, RAM, GPU, and VRAM allocation

set -e

# Output format: JSON for easy parsing
OUTPUT_FORMAT="json"

# Detection results
declare -A HARDWARE

# ============================================================================
# CPU Detection
# ============================================================================

detect_cpu() {
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
    CPU_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    CPU_THREADS=$(lscpu | grep "^Thread(s) per core:" | awk '{print $2}')
    CPU_VENDOR=$(lscpu | grep "Vendor ID" | cut -d':' -f2 | xargs)

    HARDWARE[cpu_model]="$CPU_MODEL"
    HARDWARE[cpu_cores]="$CPU_CORES"
    HARDWARE[cpu_threads]="$CPU_THREADS"
    HARDWARE[cpu_vendor]="$CPU_VENDOR"

    # Check if AMD Ryzen AI MAX+
    if echo "$CPU_MODEL" | grep -qi "Ryzen.*AI.*MAX"; then
        HARDWARE[has_npu]="true"
    else
        HARDWARE[has_npu]="false"
    fi
}

# ============================================================================
# RAM Detection
# ============================================================================

detect_ram() {
    TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    TOTAL_RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
    RAM_TYPE=$(dmidecode -t memory 2>/dev/null | grep -m1 "Type:" | grep -v "Error" | awk '{print $2}' || echo "Unknown")

    HARDWARE[ram_total_gb]="$TOTAL_RAM_GB"
    HARDWARE[ram_total_mb]="$TOTAL_RAM_MB"
    HARDWARE[ram_type]="$RAM_TYPE"
}

# ============================================================================
# GPU Detection
# ============================================================================

detect_gpu() {
    # Check for AMD GPU
    if lspci | grep -i "VGA" | grep -qi "AMD"; then
        GPU_MODEL=$(lspci | grep -i "VGA" | grep -i "AMD" | cut -d':' -f3 | xargs)
        GPU_VENDOR="AMD"

        HARDWARE[gpu_vendor]="$GPU_VENDOR"
        HARDWARE[gpu_model]="$GPU_MODEL"

        # Check if Radeon 8060S
        if echo "$GPU_MODEL" | grep -qi "8060"; then
            HARDWARE[gpu_type]="Radeon 8060S"
            HARDWARE[gpu_architecture]="RDNA 3.5"
            HARDWARE[gpu_compute_units]="40"
        fi

        # Detect VRAM if ROCm is available
        if command -v rocm-smi &> /dev/null; then
            detect_vram_rocm
        elif command -v clinfo &> /dev/null; then
            detect_vram_opencl
        else
            HARDWARE[vram_gb]="0"
            HARDWARE[vram_detection]="pending"
        fi
    else
        HARDWARE[gpu_vendor]="Unknown"
        HARDWARE[gpu_model]="No AMD GPU detected"
        HARDWARE[vram_gb]="0"
    fi
}

# ============================================================================
# VRAM Detection (ROCm)
# ============================================================================

detect_vram_rocm() {
    # Try to get VRAM from rocm-smi
    VRAM_BYTES=$(rocm-smi --showmeminfo vram 2>/dev/null | grep -i "VRAM Total Memory (B):" | awk '{print $5}' || echo "0")

    if [ "$VRAM_BYTES" -gt 0 ]; then
        # Convert bytes to GB
        VRAM_GB=$(echo "scale=2; $VRAM_BYTES / 1024 / 1024 / 1024" | bc)
        VRAM_GB_INT=$(echo "$VRAM_GB" | awk '{print int($1+0.5)}')

        HARDWARE[vram_bytes]="$VRAM_BYTES"
        HARDWARE[vram_gb]="$VRAM_GB_INT"
        HARDWARE[vram_detection]="rocm-smi"

        # Determine VRAM status
        if [ "$VRAM_GB_INT" -ge 90 ]; then
            HARDWARE[vram_status]="excellent"  # 96GB configured
            HARDWARE[vram_recommendation]="Ready for 70B+ models"
        elif [ "$VRAM_GB_INT" -ge 60 ]; then
            HARDWARE[vram_status]="good"  # 64GB configured
            HARDWARE[vram_recommendation]="Consider BIOS update for 96GB"
        elif [ "$VRAM_GB_INT" -ge 30 ]; then
            HARDWARE[vram_status]="moderate"  # 32GB configured
            HARDWARE[vram_recommendation]="BIOS update needed for large models"
        else
            HARDWARE[vram_status]="low"  # Default allocation
            HARDWARE[vram_recommendation]="BIOS configuration required"
        fi
    else
        HARDWARE[vram_gb]="0"
        HARDWARE[vram_detection]="failed"
    fi
}

# ============================================================================
# VRAM Detection (OpenCL)
# ============================================================================

detect_vram_opencl() {
    # Fallback: Try OpenCL
    VRAM_BYTES=$(clinfo 2>/dev/null | grep -i "Global memory size" | head -n1 | awk '{print $4}' || echo "0")

    if [ "$VRAM_BYTES" -gt 0 ]; then
        VRAM_GB=$(echo "scale=2; $VRAM_BYTES / 1024 / 1024 / 1024" | bc)
        VRAM_GB_INT=$(echo "$VRAM_GB" | awk '{print int($1+0.5)}')

        HARDWARE[vram_bytes]="$VRAM_BYTES"
        HARDWARE[vram_gb]="$VRAM_GB_INT"
        HARDWARE[vram_detection]="opencl"
    else
        HARDWARE[vram_gb]="0"
        HARDWARE[vram_detection]="unavailable"
    fi
}

# ============================================================================
# Storage Detection
# ============================================================================

detect_storage() {
    # Get all NVMe and SATA disks
    DISKS=$(lsblk -d -o NAME,SIZE,TYPE | grep disk | awk '{print $1":"$2}')
    HARDWARE[disks]="$DISKS"

    # Total storage
    TOTAL_STORAGE=$(lsblk -b -d -o SIZE,TYPE | grep disk | awk '{sum+=$1} END {print int(sum/1024/1024/1024)}')
    HARDWARE[storage_total_gb]="$TOTAL_STORAGE"
}

# ============================================================================
# System Compatibility Check
# ============================================================================

check_compatibility() {
    COMPATIBLE="true"
    WARNINGS=()

    # Check if AMD CPU
    if [ "${HARDWARE[cpu_vendor]}" != "AuthenticAMD" ]; then
        COMPATIBLE="false"
        WARNINGS+=("Non-AMD CPU detected - qalarc_OS optimized for AMD Ryzen AI MAX+")
    fi

    # Check if AMD GPU
    if [ "${HARDWARE[gpu_vendor]}" != "AMD" ]; then
        COMPATIBLE="false"
        WARNINGS+=("AMD GPU not detected - ROCm acceleration unavailable")
    fi

    # Check RAM (minimum 64GB recommended)
    if [ "${HARDWARE[ram_total_gb]}" -lt 64 ]; then
        WARNINGS+=("Less than 64GB RAM - may limit AI model size")
    fi

    # Check VRAM
    if [ "${HARDWARE[vram_gb]}" -lt 30 ]; then
        WARNINGS+=("Low VRAM allocation - BIOS configuration needed for large models")
    fi

    HARDWARE[compatible]="$COMPATIBLE"
    HARDWARE[warnings]="${WARNINGS[*]}"
}

# ============================================================================
# Output Functions
# ============================================================================

output_json() {
    echo "{"
    local first=true
    for key in "${!HARDWARE[@]}"; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        echo -n "  \"$key\": \"${HARDWARE[$key]}\""
    done
    echo ""
    echo "}"
}

output_human() {
    echo "=== qalarc_OS Hardware Detection ==="
    echo ""
    echo "CPU:"
    echo "  Model: ${HARDWARE[cpu_model]}"
    echo "  Cores: ${HARDWARE[cpu_cores]}"
    echo "  Vendor: ${HARDWARE[cpu_vendor]}"
    echo ""
    echo "RAM:"
    echo "  Total: ${HARDWARE[ram_total_gb]}GB"
    echo "  Type: ${HARDWARE[ram_type]}"
    echo ""
    echo "GPU:"
    echo "  Vendor: ${HARDWARE[gpu_vendor]}"
    echo "  Model: ${HARDWARE[gpu_model]}"
    echo "  VRAM: ${HARDWARE[vram_gb]}GB (${HARDWARE[vram_detection]})"
    if [ -n "${HARDWARE[vram_status]}" ]; then
        echo "  Status: ${HARDWARE[vram_status]}"
        echo "  Recommendation: ${HARDWARE[vram_recommendation]}"
    fi
    echo ""
    echo "Storage:"
    echo "  Total: ${HARDWARE[storage_total_gb]}GB"
    echo ""
    echo "Compatibility:"
    echo "  Compatible: ${HARDWARE[compatible]}"
    if [ -n "${HARDWARE[warnings]}" ]; then
        echo "  Warnings: ${HARDWARE[warnings]}"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --json)
                OUTPUT_FORMAT="json"
                shift
                ;;
            --human)
                OUTPUT_FORMAT="human"
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Run detection
    detect_cpu
    detect_ram
    detect_gpu
    detect_storage
    check_compatibility

    # Output results
    if [ "$OUTPUT_FORMAT" = "json" ]; then
        output_json
    else
        output_human
    fi
}

main "$@"
