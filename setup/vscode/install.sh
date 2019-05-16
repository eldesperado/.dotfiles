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

vscode_dir="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

for f in ~/.setup/lib/*; do
  source $f;
done

if ! yes_no_prompt "Install VSCode extensions & themes? "; then
  exit
fi

info "Installing VSCode extensions & themes..."
code --install-extension WakaTime.vscode-wakatime
code --install-extension alexdima.copy-relative-path
code --install-extension xaver.clang-format
code --install-extension zhuangtongfa.material-theme
info "Installed VSCode extensions & themes..."