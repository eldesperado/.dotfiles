#! /usr/local/env bash

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

git_dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
source "$git_dir/../lib/log.sh"
source "$git_dir/../lib/prompt.sh"

if ! yes_no_prompt "Configure git? "; then
  exit
fi

os=$(uname -s)

user "Enter your git name: "
read -r name
user "Enter your git e-mail: "
read -r email

gitconfig_path="$HOME/.gitconfig"

# TODO: make this optional using some prompt
if [ ! -f "$gitconfig_path" ]; then
  cp "$git_dir/gitconfig.example" "$gitconfig_path"
fi

git config user.name "$name"
git config user.email "$email"

if ! yes_no_prompt "Set up Github token?"; then
  exit
fi

user "Enter your github auth token: "
read -r token

cp -f "$git_dir/github_token.zsh.example" "$git_dir/github_token.zsh"

if [ "$os" = "Darwin" ]; then
  sed -i "" "s/__TOKEN__/$token/g" "$git_dir/github_token.zsh"
else
  sed -i"" "s/__TOKEN__/$token/g" "$git_dir/github_token.zsh"
fi