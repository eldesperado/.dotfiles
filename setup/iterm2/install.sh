#!/bin/sh

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

iterm2_dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

for f in ~/.setup/lib/*; do
  source $f;
done

if ! yes_no_prompt "Install iTerm2 profile? "; then
  exit
fi

info "Setting up iTerm profile..."
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$iterm2_dir"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -int 1
success "Set up iTerm."

info "Linking iTerm Profiles directory..."
mkdir -p "~/Library/Application Support/iTerm2/"
rm -rf "~/Library/Application Support/iTerm2/DynamicProfiles"
ln -sfhF "$iterm2_dir/profiles" ~/Library/Application\ Support/iTerm2/DynamicProfiles
success "Linked iTerm Profiles directory."