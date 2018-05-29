#! /usr/local/env bash

# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  TARGET="$(readlink "$SOURCE")"
  if [[ $TARGET == /* ]]; then
    SOURCE="$TARGET"
  else
    DIR="$( dirname "$SOURCE" )"
    SOURCE="$DIR/$TARGET" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  fi
done

theme_dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
source "$theme_dir/../lib/log.sh"
source "$theme_dir/../lib/prompt.sh"

if ! yes_no_prompt "Install Terminal & iTerm2 theme? "; then
  exit
fi

info "Installing Terminal theme..."
# Use a modified version of the theme by default in Terminal.app
osascript <<EOD
tell application "Terminal"
	local allOpenedWindows
	local initialOpenedWindows
	local windowID
	set themeName to "OneDark"
	(* Store the IDs of all the open terminal windows. *)
	set initialOpenedWindows to id of every window
	(* Open the custom theme so that it gets added to the list
	   of available terminal themes (note: this will open two
	   additional terminal windows). *)
	do shell script "open '$theme_dir/onedark/" & themeName & ".terminal'"
	(* Wait a little bit to ensure that the custom theme is added. *)
	delay 1
	(* Set the custom theme as the default terminal theme. *)
	set default settings to settings set themeName
	(* Get the IDs of all the currently opened terminal windows. *)
	set allOpenedWindows to id of every window
	repeat with windowID in allOpenedWindows
		(* Close the additional windows that were opened in order
		   to add the custom theme to the list of terminal themes. *)
		if initialOpenedWindows does not contain windowID then
			close (every window whose id is windowID)
		(* Change the theme for the initial opened terminal windows
		   to remove the need to close them in order for the custom
		   theme to be applied. *)
		else
			set current settings of tabs of (every window whose id is windowID) to settings set themeName
		end if
	end repeat
end tell
EOD
success "Installed Terminal theme."

info "Installing iTerm2 theme..."
# Install the theme for iTerm
open "$theme_dir/onedark/OneDark.itermcolors"
success "Installed iTerm2 theme."