# env
brew install --cask 'homebrew/cask-versions/adoptopenjdk8'

# devs
brew install 'iterm2'
brew install 'visual-studio-code'
brew install 'fork'

# productivity
brew install 'alfred'
brew install 'flux'
brew install 'popclip'
brew install 'hammerspoon'
brew install 'karabiner-elements'
brew install '1password'
brew install 'simplenote'
brew install 'the-unarchiver'

# basics
brew install 'dropbox'
brew install 'spotify'

# fonts
brew install 'font-jetbrains-mono'

# theme
brew install romkatv/powerlevel10k/powerlevel10k
echo "source $(brew --prefix)/opt/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc