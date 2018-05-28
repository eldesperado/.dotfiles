#!/usr/local/env bash

homebrew_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $homebrew_dir
source "$homebrew_dir/../lib/log.sh"
source "$homebrew_dir/../lib/prompt.sh"

if ! yes_no_prompt "Install Homebrew formulae? "; then
  exit
fi

# Install the correct homebrew for each OS type
if test "$(uname)" = "Darwin"
then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
fi

# Install Homebrew
if ! type "brew" > /dev/null; then
  info "Installing Homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  success "Installed Homebrew."
fi

if ! type "brew" > /dev/null; then
  fail "Installing Homebrew failed. Aborting..."
fi

info "Updating formulae..."
brew update
success "Updated formulae."

info "Upgrading formulae..."
brew upgrade
success "Upgraded installed formulae."

info "Tapping into taps..."
source "$homebrew_dir/taps.sh"
success "Tapped all taps."

info "Installing Homebrew formulae..."
source "$homebrew_dir/packages.sh"
success "Installed Homebrew formulae."

info "Installing Homebrew casks..."
source "$homebrew_dir/casks.sh"
success "Installed casks."

info "Installing Homebrew casks..."
source "$homebrew_dir/casks.sh"
success "Installed casks."

success "Successfully installed Homebrew."
exit