#!/bin/bash

  

# Author: GoNT

# Date Created: 12/07/2024

# Date Modified: 19/07/2024

# Description:

#   This script searches and prints all log socket at "https://dlqos-zalo.zdn.vn/ios" using the raw uid 

#   and user input time log. After you choose index of logs that need download

  
# Import the cookie file
source "$(dirname "$0")/zalo_credential.sh"

  

# Global constants
IOS_HOME_URL_LOG="https://dlqos-zalo.zdn.vn/ios"
SPECIFIC_URL_LOG=""

function zaloVersion {
    let _rawUID=${1}
    html_result=$(curl --silent -sSL "https://toolkit.zaloapp.com/v3/profile?user_id="${_rawUID}"&token=FCL7UzjZadjQJEIjJn5UTlmjNoE6Z1Aw" \
                        -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
                        -H "cookie: ${TOOLKIT_COOKIE}" \
                        -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0")

    TagClientVersion=$(printf "%s" "${html_result}" | grep 'ClientVersion')
    ClientVersion=$(printf "%s" "${TagClientVersion}" | sed 's/.*ClientVersion:(\([^)]*\).*/\1/')
    echo ${ClientVersion}
}

function downloadFile {
  local output_file=$1
  local url=$2
  local http_code
  local error_msg

  # Use a temporary file to capture curl output
  local tmp_file=$(mktemp)

  http_code=$(curl --write-out '%{http_code}' -s -S -o "$tmp_file" "$url" \
                -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
                -H "cookie: ${QOS_LOG_COOKIE}" \
                -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0" \
                2>&1)

  if [[ $http_code -eq 200 ]]; then
    mv "$tmp_file" "$output_file"
  else
    error_msg=$(cat "$tmp_file")
    rm "$tmp_file"
  fi

  echo "$http_code|$error_msg"
}

function searchAndGetAllLog {
  let _rawUID=$1
  let _zaloVersion=$2
  SPECIFIC_URL_LOG=$IOS_HOME_URL_LOG"/"$_zaloVersion"/"$3"/"
  
  
  html_output=$(curl -s -sSL $SPECIFIC_URL_LOG \
                      -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" \
                      -H "cookie: ${QOS_LOG_COOKIE}" \
                      -H "user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36 Edg/126.0.0.0")

  # Check if the response contains an error message or is empty
  if [[ -z "$html_output" || "$html_output" == *"error"* || "$html_output" == *"unauthorized"* ]]; then
    echo "ERROR: Unable to fetch logs. Please check your cookies and try again."
    echo "Domain: $SPECIFIC_URL_LOG"
    
    # Ask user if they want to print html_output
    read -p "Do you want to print the html_output for debugging? (y/N): " print_output
    if [[ $print_output == "y" || $print_output == "Y" ]]; then
      echo "HTML Output:"
      echo "$html_output"
    fi
    
    exit 1
  fi

  all_href_html=$(printf "%s" "${html_output}" | grep "href=\"${_rawUID}" | sed 's/.*href="\([^"]*\).*/\1/')
  echo ${all_href_html[@]}
}

function unzipFile {
  full_path=$1
  full_file_name=$(basename -- "$full_path") #full name without path. ex: example.zip
  file_name="${full_file_name%.*}" #file name without extension. ex: example
  f_dest="$ROOT_PATH_UNZIP_LOG/$file_name" #create full path for new location
  if [ ! -d "$f_dest" ] #if not exist
  then 
      mkdir -p $f_dest
      unzip -q $full_path -d $f_dest
      echo "✅ $f_dest created and unzipped"
      return 0
  else
      echo "$f_dest already existed"
      read -p "Do you want to overwrite the existing files? (y/N): " overwrite
      if [[ $overwrite == "y" || $overwrite == "Y" ]]; then
          unzip -q -o $full_path -d $f_dest
          echo "✅ $f_dest overwritten and unzipped"
          return 0
      else
          echo "Skipping $f_dest"
          return 1
      fi
  fi
}

function openFoldersInVSCode {
  local folders=("$@")
  if [ ${#folders[@]} -gt 0 ]; then
    echo
    read -p "Do you want to open the unzipped folder(s) in VS Code? (y/N): " open_vscode
    if [[ $open_vscode == "y" || $open_vscode == "Y" ]]; then
      if command -v code &> /dev/null; then
        for folder in "${folders[@]}"; do
          code "$folder"
          echo "✅ Opened $folder in VS Code"
        done
      else
        echo "❌ VS Code command-line tool 'code' not found. Please make sure it's installed and in your PATH."
      fi
    fi
  fi
}

function showHelp {
    # Display Help
    echo
    echo "Syntax: get_log UID LOG_TIME"
    echo "Parametes:"
    echo " UID          Input raw UID need searches logs. Ex: 176855177"
    echo " LOG_TIME     Input time need searches logs Ex: 20204_07_17"
    echo
}

if [[ -z $1 || -z $2 ]]
then
  showHelp
  exit 1
fi

ROOT_PATH_UNZIP_LOG=$HOME"/Documents/Work/Logs"
ROOT_PATH_DOWNLOAD=$HOME"/Downloads/"
CUR_DATE=$(date +'%Y_%m_%d')
rawUID=$1
INPUT_DATE=$2
zaloVersion=$(zaloVersion $rawUID)

if [[ -z $INPUT_DATE ]]; then #If INPUT_DATE empty then assign CUR_DATE
  INPUT_DATE=$CUR_DATE
fi

searchAndGetAllLog $rawUID $zaloVersion $INPUT_DATE

all_log=$( searchAndGetAllLog $rawUID $zaloVersion $INPUT_DATE )
if [[ "$all_log" == ERROR* ]]; then
  echo "$all_log"
  exit 1
fi

total_href=0
declare -a href_log_list=()
for href in ${all_log[@]}; do
  href_log_list+=($href)
  total_href=$(( $total_href + 1 ))
done

#Show result on screen
if [[ $total_href -eq 0 ]]
then
  echo "Not found log of uid: ${rawUID} in ${INPUT_DATE}"
  exit 1
fi

echo

#Question and wait user input
declare -a file_path_downloaded=()
declare -a file_path_download_success=()

while true; do
  CHOOSE_ITEMS=()
  while true; do
    echo
    echo "Found ${total_href} logs of ${rawUID} in ${INPUT_DATE}"
    for i in "${!href_log_list[@]}"; do
      echo " ${i}. ${href_log_list[$i]}"
    done
    echo

    read -p "Please choose the item(s) that need to be downloaded (separating with a space. Ex: 0 1): " key
    IFS=$' ' read -ra CHOOSE_ITEMS <<< $key
    if [[ ${#CHOOSE_ITEMS[@]} -gt 0 ]]; then
      break
    fi
    echo "Invalid selection. Please try again."
  done

  for i_item in "${CHOOSE_ITEMS[@]}"; do
    url_selected=${href_log_list[$i_item]}
    if [[ ! -z $url_selected ]]; then
      full_url_log_will_download=$SPECIFIC_URL_LOG$url_selected
      dest_direction_file=$ROOT_PATH_DOWNLOAD$url_selected
      file_path_downloaded+=($dest_direction_file)
      if [[ -f $dest_direction_file ]]; then
        echo "💾 ${dest_direction_file} already exists"
        file_path_download_success+=($dest_direction_file)
      else
        download_success=0

        echo "$SPECIFIC_URL_LOG and $url_selected"
        while [[ $download_success -eq 0 ]]; do
          dl_result=$( downloadFile "$dest_direction_file" "$full_url_log_will_download" )
          dl_status=$(echo "$dl_result" | cut -d'|' -f1)
          dl_error=$(echo "$dl_result" | cut -d'|' -f2-)
          if [[ $dl_status -eq 200 ]]; then
            echo "✅ ${url_selected} downloaded successfully to \"${dest_direction_file}\""
            file_path_download_success+=($dest_direction_file)
            download_success=1
          else
            echo "❌ ${url_selected} download failed"
            echo "Error: $dl_error"
            echo "HTTP Status Code: $dl_status"
            read -p "Do you want to (r)etry downloading, (s)kip this file, or (q)uit? (r/s/q): " user_choice
            case $user_choice in
              r|R) continue ;;
              s|S) break ;;
              q|Q) 
                exit 1
                break 2 ;;
              *) echo "Invalid choice. Retrying download." ;;
            esac
          fi
        done
      fi
    fi
  done

  if [[ ${#file_path_download_success[@]} -gt 0 ]]; then
    break
  fi
  echo "No files were successfully downloaded. Please try again."
done

if [[ ${#file_path_download_success[@]} -eq 0 ]]; then
  echo "No files were successfully downloaded. Exiting."
  exit 1
fi

# Question to UNZIP log
echo
read -t 10 -p "Do you want to UNZIP to Logs folder (Y/N): " is_unzip #10s timeout
case $is_unzip in
  y|Y)
    unzipped_folders=()
    for file_path in "${file_path_download_success[@]}"; do
      if unzipFile "$file_path"; then
        unzipped_folders+=("$ROOT_PATH_UNZIP_LOG/$(basename "${file_path%.*}")")
      fi
    done
    
    openFoldersInVSCode "${unzipped_folders[@]}"
    ;;
  *)
    echo "Unzip skipped. Program is quitting."
    ;;
esac

exit 0
