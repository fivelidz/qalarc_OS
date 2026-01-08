#!/usr/bin/env bash
# qalarc-portable-gui: KDE/Qt GUI for creating portable USB drives

# Check for kdialog (KDE) or zenity (GTK fallback)
if command -v kdialog &> /dev/null; then
    GUI="kdialog"
elif command -v zenity &> /dev/null; then
    GUI="zenity"
else
    echo "Error: No GUI toolkit found. Please install kdialog or zenity."
    echo "Or use the CLI version: sudo qalarc-create-portable"
    exit 1
fi

# Helper functions for either toolkit
show_info() {
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "qalarc Portable Creator" --msgbox "$1"
    else
        zenity --info --title="qalarc Portable Creator" --text="$1" --width=400
    fi
}

show_error() {
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "qalarc Portable Creator" --error "$1"
    else
        zenity --error --title="qalarc Portable Creator" --text="$1" --width=400
    fi
}

show_warning() {
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "qalarc Portable Creator" --warningyesno "$1"
    else
        zenity --question --title="qalarc Portable Creator" --text="$1" --width=400
    fi
}

show_progress() {
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "Creating Portable USB" --progressbar "$1" 0
    else
        zenity --progress --title="Creating Portable USB" --text="$1" --pulsate --auto-close
    fi
}

get_device_list() {
    # Get list of removable devices
    lsblk -d -n -o NAME,SIZE,MODEL,TRAN | grep -E "usb|removable" | while read line; do
        name=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $2}')
        model=$(echo "$line" | awk '{$1=""; $2=""; print}' | xargs)
        echo "/dev/$name|$size - $model"
    done
}

select_device() {
    devices=$(get_device_list)
    
    if [ -z "$devices" ]; then
        show_error "No removable USB devices found.\n\nPlease connect a USB drive and try again."
        exit 1
    fi
    
    if [ "$GUI" = "kdialog" ]; then
        # Build kdialog radiolist
        items=""
        first=true
        while IFS='|' read -r dev desc; do
            if [ "$first" = true ]; then
                items="$items $dev \"$desc\" on"
                first=false
            else
                items="$items $dev \"$desc\" off"
            fi
        done <<< "$devices"
        
        DEVICE=$(eval kdialog --title \"Select Target Device\" --radiolist \"Choose the USB drive to use:\n\nWARNING: All data will be erased!\" $items)
    else
        # Build zenity list
        DEVICE=$(echo "$devices" | tr '|' '\n' | zenity --list \
            --title="Select Target Device" \
            --text="Choose the USB drive to use:\n\nWARNING: All data will be erased!" \
            --column="Device" --column="Description" \
            --width=500 --height=300)
    fi
    
    echo "$DEVICE"
}

select_options() {
    if [ "$GUI" = "kdialog" ]; then
        OPTIONS=$(kdialog --title "Configuration" --checklist "Select what to include:" \
            "ai_models" "AI Models (/var/lib/ollama)" off \
            "user_data" "User Data (/home)" off \
            "persistence" "Persistence Partition" on)
    else
        OPTIONS=$(zenity --list --checklist \
            --title="Configuration" \
            --text="Select what to include:" \
            --column="Include" --column="Option" --column="Description" \
            FALSE "ai_models" "AI Models (/var/lib/ollama)" \
            FALSE "user_data" "User Data (/home)" \
            TRUE "persistence" "Persistence Partition" \
            --width=500 --height=300 --separator=" ")
    fi
    
    echo "$OPTIONS"
}

run_creation() {
    local device="$1"
    local options="$2"
    
    # Build command
    CMD="pkexec qalarc-create-portable --device ${device#/dev/} --non-interactive"
    
    if [[ "$options" == *"ai_models"* ]]; then
        CMD="$CMD --ai-models"
    fi
    
    if [[ "$options" == *"user_data"* ]]; then
        CMD="$CMD --user-data"
    fi
    
    if [[ "$options" != *"persistence"* ]]; then
        CMD="$CMD --no-persistence"
    fi
    
    # Run with progress
    if [ "$GUI" = "kdialog" ]; then
        # Create a temp file for output
        OUTFILE=$(mktemp)
        
        # Run in background and show progress
        $CMD > "$OUTFILE" 2>&1 &
        PID=$!
        
        DBUSREF=$(kdialog --title "Creating Portable USB" --progressbar "Initializing..." 100)
        
        while kill -0 $PID 2>/dev/null; do
            # Try to parse progress from output
            if grep -q "Progress:" "$OUTFILE"; then
                PCT=$(grep "Progress:" "$OUTFILE" | tail -1 | grep -oE "[0-9]+%" | tr -d '%')
                [ -n "$PCT" ] && qdbus $DBUSREF Set "" value "$PCT"
            fi
            
            LAST_LINE=$(tail -1 "$OUTFILE" 2>/dev/null)
            [ -n "$LAST_LINE" ] && qdbus $DBUSREF setLabelText "$LAST_LINE"
            
            sleep 1
        done
        
        qdbus $DBUSREF close
        
        wait $PID
        RESULT=$?
        
        if [ $RESULT -eq 0 ]; then
            show_info "Portable USB created successfully!\n\nYou can now boot any computer from this USB drive.\n\nSee the guide at:\n/etc/qalarc-portable/PORTABLE_BOOT_GUIDE.md"
        else
            show_error "Failed to create portable USB.\n\nCheck the logs for details:\n$(tail -20 "$OUTFILE")"
        fi
        
        rm -f "$OUTFILE"
    else
        # Zenity progress
        $CMD 2>&1 | zenity --progress \
            --title="Creating Portable USB" \
            --text="Starting..." \
            --pulsate \
            --auto-close \
            --width=400
        
        RESULT=${PIPESTATUS[0]}
        
        if [ $RESULT -eq 0 ]; then
            show_info "Portable USB created successfully!\n\nYou can now boot any computer from this USB drive."
        else
            show_error "Failed to create portable USB. Please check the terminal for errors."
        fi
    fi
}

# Main flow
main() {
    # Welcome screen
    if [ "$GUI" = "kdialog" ]; then
        kdialog --title "qalarc Portable Creator" --msgbox \
            "Welcome to the qalarc_OS Portable Creator!\n\nThis wizard will help you create a USB drive that:\n• Boots on ANY computer (UEFI and BIOS)\n• Loads entirely into RAM for maximum speed\n• Works even after USB is removed\n• Optionally includes AI models and your data\n\nRequirements:\n• USB drive or SSD (16GB+ recommended)\n• Target computer needs 8GB+ RAM\n\nClick OK to continue."
    else
        zenity --info --title="qalarc Portable Creator" --width=500 --text=\
"Welcome to the qalarc_OS Portable Creator!

This wizard will help you create a USB drive that:
• Boots on ANY computer (UEFI and BIOS)
• Loads entirely into RAM for maximum speed
• Works even after USB is removed
• Optionally includes AI models and your data

Requirements:
• USB drive or SSD (16GB+ recommended)
• Target computer needs 8GB+ RAM

Click OK to continue."
    fi
    
    # Select device
    DEVICE=$(select_device)
    [ -z "$DEVICE" ] && exit 0
    
    # Select options
    OPTIONS=$(select_options)
    [ -z "$OPTIONS" ] && OPTIONS="persistence"  # Default
    
    # Calculate sizes and show summary
    BASE_SIZE="~4GB"
    AI_SIZE=""
    USER_SIZE=""
    
    [[ "$OPTIONS" == *"ai_models"* ]] && AI_SIZE="\n• AI Models: ~$(du -sh /var/lib/ollama 2>/dev/null | cut -f1 || echo '10-50GB')"
    [[ "$OPTIONS" == *"user_data"* ]] && USER_SIZE="\n• User Data: ~$(du -sh /home 2>/dev/null | cut -f1 || echo 'varies')"
    
    SUMMARY="You are about to create a portable qalarc_OS USB.\n\nTarget: $DEVICE\n\nIncluded:\n• Base System: $BASE_SIZE$AI_SIZE$USER_SIZE\n\nThis will ERASE ALL DATA on $DEVICE!\n\nContinue?"
    
    if ! show_warning "$SUMMARY"; then
        exit 0
    fi
    
    # Final confirmation
    if ! show_warning "FINAL WARNING!\n\nAll data on $DEVICE will be permanently destroyed.\n\nType of device: $(lsblk -d -n -o MODEL $DEVICE)\n\nAre you absolutely sure?"; then
        exit 0
    fi
    
    # Run creation
    run_creation "$DEVICE" "$OPTIONS"
}

main "$@"
