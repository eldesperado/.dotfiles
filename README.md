
<div align="left">
  <h1>TrungPNN's Dotfiles</h1>
</div>
<div align="left">
  <a href="https://opensource.org/licenses/mit-license.php">
    <img alt="MIT Licence" src="https://badges.frapsoft.com/os/mit/mit.svg?v=103" />
  </a>
  <a href="https://github.com/ellerbrock/open-source-badge/">
    <img alt="Open Source Love" src="https://badges.frapsoft.com/os/v1/open-source.svg?v=103" />
  </a>
</div>

<br />

**This dotfiles** contains awesome configurations for CLI commands and `macOS` environments, along with powerfully customized Vim, Zsh.

<div align="center">
<img alt="Screenshot of my shell prompt" src="https://i.imgur.com/LXthgyi.png" width="90%" />
</div>

## Installation
Warning: If you want to give these dotfiles a try, you should first fork this repository, review the code, and remove things you don’t want or need. Don’t blindly use my settings unless you know what that entails. Use at your own risk!

After cloning this repo, run `install` to automatically set up the development
environment. Note that the install script is idempotent: it can safely be run
multiple times.

Dotfiles uses [Dotbot][dotbot] for installation.

```bash
$ git clone https://github.com/eldesperado/.dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles
$ ./install
```

### Sensible macOS defaults

When setting up a new Mac, you may want to set some sensible macOS defaults:

```bash
$ sh ~/.setup/macos/.macos
```

### Install Homebrew formulae

When running `install` script, it will ask you whether you want to install [Homebrew](https://brew.sh/) and its formulae or not.

## Author

| [![twitter/trungpnn](https://secure.gravatar.com/avatar/06042cc986e2cf5e252174247411e0eb)](https://twitter.com/trungpnn "Follow @trunpnn on Twitter") |
|---|
| [Nhat Trung](https://twitter.com/trungpnn) |

## Thanks to…
* Mathias Bynens and [his _macOS Setup_ repository](https://github.com/mathiasbynens/dotfiles)
* Amir Salihefendic and [his _VIM Setup_ repository](https://github.com/amix/vimrc)
* Felix Jung and [his _dofiles_ repository](https://github.com/felixjung/dotfiles)

License
-------

Copyright (c) 2013-2017 Pham Nguyen Nhat Trung. Released under the MIT License. See
[LICENSE.md][license] for details.

[dotbot]: https://github.com/anishathalye/dotbot
[license]: LICENSE.md