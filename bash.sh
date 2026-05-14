#!/bin/bash

# Define variables
SOUND_SOURCE="./fahhhhh.mp3"
SOUND_DEST_DIR="$HOME/.local/share/sound"
SOUND_DEST_FILE="$SOUND_DEST_DIR/fahhhhh.mp3"
PROFILE="$HOME/.bashrc"

# Check if the MP3 exists in the current folder
if [ ! -f "$SOUND_SOURCE" ]; then
    echo " Error: .mp3 not found! Please run this script from inside the cloned repository."
    exit 1
fi

echo "Copying sound file to $SOUND_DEST_DIR..."
mkdir -p "$SOUND_DEST_DIR"
cp "$SOUND_SOURCE" "$SOUND_DEST_FILE"

echo "Adding hook to $PROFILE..."
# Append the function to the end of .bashrc. 
# Using 'EOF' prevents variables from expanding prematurely.
cat << 'EOF' >> "$PROFILE"

# --- Faaah Sound on Failed Command ---
play_failed_sound() {
    local exit_status=$?
    if [ $exit_status -ne 0 ]; then
        pw-play ~/.local/share/sound/fahhhhh.mp3 &> /dev/null & disown
    fi
    return $exit_status
}
PROMPT_COMMAND="play_failed_sound; $PROMPT_COMMAND"
# -------------------------------------
EOF

echo "Installation complete! Please restart your terminal or run: source ~/.bashrc"
