TrungPNN's Dotfiles
========
![Screenshot of my shell prompt](https://i.imgur.com/sCZeEVj.png)

# Installation
Warning: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

After cloning this repo, run `install` to automatically set up the development
environment. Note that the install script is idempotent: it can safely be run
multiple times.

Dotfiles uses [Dotbot][dotbot] for installation.

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
cd 'YOUR_CLONED_DOTFILES_FOLDER'
sh ./setup/macos/.macos
```

### Install Homebrew formulae

When setting up a new Mac, you may want to install some common [Homebrew](https://brew.sh/) formulae (after installing Homebrew-bundle, of course) using [Homebrew-bundle](https://github.com/Homebrew/homebrew-bundle):

```bash
cd 'YOUR_CLONED_DOTFILES_FOLDER'
brew bundle ./setup/Brewfile
```

## Author

| [![twitter/trungpnn](https://secure.gravatar.com/avatar/06042cc986e2cf5e252174247411e0eb)](https://twitter.com/trungpnn "Follow @trunpnn on Twitter") |
|---|
| [Nhat Trung](https://twitter.com/trungpnn) |

## Thanks to…
* Mathias Bynens [his _macOS Setup_ repository](https://github.com/mathiasbynens/dotfiles)

License
-------

Copyright (c) 2013-2017 Pham Nguyen Nhat Trung. Released under the MIT License. See
[LICENSE.md][license] for details.

[dotbot]: https://github.com/anishathalye/dotbot
[license]: LICENSE.md