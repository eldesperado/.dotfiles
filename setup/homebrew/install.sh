#!/usr/local/env bash

# https://stackoverflow.com/questions/59895/getting-the-source-directory-of-a-bash-script-from-within/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
homebrew_dir="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"

for f in ~/.setup/lib/*; do
  source $f;
done

if ! yes_no_prompt "Install Homebrew formulae? "; then
  exit
fi

# Install the correct homebrew for each OS type
if test "$(uname)" = "Darwin"
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
elif test "$(expr substr $(uname -s) 1 5)" = "Linux"
then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
fi

# Install Homebrew
if ! type "brew" > /dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
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

info "Installing Homebrew mas..."
source "$homebrew_dir/mas.sh"
success "Installed mas."

info "Remove outdated versions from the cellar..."
brew cleanup
success "Removed outdated versions."

success "Successfully installed Homebrew."
exit