#! /usr/bin/bash

sourceDirectory="$(realpath "$1")"
destinationDirectory="$(realpath "$2")"
backupName="$(basename $SOURCE)"

timeFormat='%Y%m%d-%H%M%S'
timeRightNow="$(date +$timeFormat)"

function _punt() {
  local msg="$1"
  echo "$msg"
  exit 1
}

#################################################
# Guard
#################################################
function _dir_exists() {
  local dir="$1"
  [ -d "$dir" ]
}

for dir in "$sourceDirectory" "$destinationDirectory"; do
  _dir_exists "$dir" || _punt "Your source or destination dir do not exist"
done

#################################################
# Get a consistent tag for the backup
#################################################
function _get_tag() {
  basename "$sourceDirectory" \
    | tr -d ' ' \
    | tr '[:upper:]' '[:lower:]'
}

#################################################
# Get previous backup
#################################################
function _get_previous_backup() {
  local tag
  tag=$(_get_tag "$sourceDirectory")
  find "$destinationDirectory" \
    -type d \
    -regextype egrep \
    -regex "$destinationDirectory/$tag-[0-9]{8}-[0-9]{6}" \
    | sort -n \
    | tail -n 1
}

function main() {
  local _previousBackup _destinationBackupDir
  _previousBackup="$(_get_previous_backup)"

  # If we have a previous backup, rsync likes a trailing slash
  [ -n "$_previousBackup" ] && _previousBackup="$_previousBackup/"

  _destinationBackupDir="$destinationDirectory/$(_get_tag)-$timeRightNow/"

  rsync -ravP --size-only ${_previousBackup:+'--link-dest'} "$_previousBackup" "$sourceDirectory/" "$_destinationBackupDir"
}

main
