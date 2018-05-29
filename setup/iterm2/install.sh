#!/bin/sh
set -e

iterm2_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$iterm2_dir/../lib/log.sh"
source "$iterm2_dir/../lib/prompt.sh"

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