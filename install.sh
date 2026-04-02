REPO="https://raw.githubusercontent.com/HEG0/FAHHH/master"
INSTALL_DIR="$HOME/.local/share/fahhh"
MP3_FILE="$INSTALL_DIR/fahhh.mp3"
WAV_FILE="$INSTALL_DIR/fahhh.wav"
FISH_FUNC="$HOME/.config/fish/functions/fish_command_not_found.fish"

mkdir -p "$INSTALL_DIR"

if [[ -n "${BASH_SOURCE[0]:-}" && -f "$(dirname "${BASH_SOURCE[0]}")/assets/fahhh.mp3" ]]; then
	cp -r "$(dirname "${BASH_SOURCE[0]}")"/assets/* "$INSTALL_DIR"
else
	curl -fsSL -o "$MP3_FILE" "$REPO/assets/fahhh.mp3" -o "$WAV_FILE" "$REPO/assets/fahhh.wav"
fi

if [[ ! -f "$MP3_FILE" ]]; then
	echo "failed to get fahhh.mp3"
	exit 1
fi

if [[ ! -f "$WAV_FILE" ]]; then
	echo "failed to get fahhh.wav"
	exit 1
fi

SOUND_FILE="$MP3_FILE"
if [[ "$OSTYPE" == "darwin"* ]]; then
	PLAYER="afplay"
elif command -v paplay &>/dev/null; then
	PLAYER="paplay"
elif command -v aplay &>/dev/null; then
	PLAYER="aplay"
    SOUND_FILE="$WAV_FILE"
else
	echo "no supported audio player found (afplay, paplay, aplay)"
	exit 1
fi

read -r -d '' HANDLER_ZSH <<EOF || true

_play_error_sound() {
  local exit_code=\$?
  if [[ \$exit_code -ne 0 ]]; then
    ($PLAYER "$SOUND_FILE" &>/dev/null &)
  fi
}
precmd_functions+=(_play_error_sound)
EOF

read -r -d '' HANDLER_BASH <<EOF || true
_play_error_sound() {
  local exit_code=\$?
  if [[ \$exit_code -ne 0 ]]; then
    ($PLAYER "$SOUND_FILE" &>/dev/null &)
  fi
}
PROMPT_COMMAND="_play_error_sound\${PROMPT_COMMAND:+;\$PROMPT_COMMAND}"
EOF

inject_rc() {
	local rc_file="$1"
	local snippet="$2"

	if grep -q "command_not_found_hand" "$rc_file" 2>/dev/null; then
		echo "fahhh is already installed in $rc_file — skipping."
		return
	fi

	echo "$snippet" >>"$rc_file"
	echo "fahhh installed into $rc_file"
	echo "restart your terminal or run: source $rc_file"
}


[[ -f "$HOME/.zshrc" ]] && inject_rc "$HOME/.zshrc" "$HANDLER_ZSH"
[[ -f "$HOME/.bashrc" ]] && inject_rc "$HOME/.bashrc" "$HANDLER_BASH"

exit 0
