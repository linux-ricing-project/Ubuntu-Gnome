#!/bin/bash

################################################################################
# Description:
#    Script that change some icon folders based in Korla Folders
#
################################################################################
# Autor: Frank Junior <frankcbjunior@gmail.com>
# Desde: 15-04-2020
# Versão: 1
################################################################################

icons_folder="${HOME}/.local/share/icons/korla/places/scalable"

set -e

# ============================================
# Função de debug
# ============================================
function log(){
  echo "[LOG] $*"
}

# ============================================
# Function to validations
# ============================================
function validation(){
  if [ ! -d "$icons_folder" ];then
    echo "icon folder not exist"
    echo "please, run '03-install_themes_and_icons.sh' script first"
    exit 1
  fi
}

# ============================================
# function auxiliar to set icon of a specific folder
# $1 --> folder path
# $2 --> icon path
# ============================================
function set_icon_folder(){
  local folder="$1"
  local icon="$2"

  if [ -d "$folder" ];then
    log "applying icon to $folder"
    gio set "$folder" -t string metadata::custom-icon file://${icon}
  fi
}

# ============================================
# Function that change folder icon in all HOME's hidden folder
# ============================================
function set_home_hidden_folders(){
  for hidden_folder in $(find $HOME -maxdepth 1 -type d -iname ".?*");do
    set_icon_folder "$hidden_folder" "${icons_folder}/folder-yellow.svg"
  done
}

# ============================================
# Function that change folder icon in all Github repositories
# ============================================
function set_icon_all_github_folders(){
  local root_folder="${HOME}/Dropbox/development"

  if [ -d "$root_folder" ];then
    for git_folder in $(find "$root_folder" -iname ".git"); do
      if grep -q "github" "$git_folder/config";then
        set_icon_folder "$(dirname $git_folder)" "${icons_folder}/folder-github.svg"
      fi
    done
  fi

}

# ============================================
# function main that change folder icons
# ============================================
function set_icon_all_folders(){
  # my bin folder
  set_icon_folder "$HOME/bin" "${icons_folder}/folder-green.svg"
  # dropbox folder
  set_icon_folder "$HOME/Dropbox" "${icons_folder}/folder-dropbox.svg"
  # dropbox image folders
  set_icon_folder "$HOME/Dropbox/Images" "${icons_folder}/folder-image.svg"
  set_icon_folder "$HOME/Dropbox/Images/Fotos" "${icons_folder}/folder-pictures.svg"
  # my folder of Linux ISOs
  set_icon_folder "$HOME/Dropbox/linux_distribuições" "${icons_folder}/distributor-logo.svg"
  # development folders
  set_icon_folder "$HOME/Dropbox/development" "${icons_folder}/folder-development.svg"
  set_icon_folder "$HOME/Dropbox/development/workspace" "${icons_folder}/folder-development.svg"
  set_icon_folder "$HOME/Dropbox/development/workspace/github" "${icons_folder}/folder-github.svg"
  # Music folders
  set_icon_folder "$HOME/Dropbox/Music" "${icons_folder}/folder-music.svg"
  set_icon_folder "$HOME/Dropbox/Music/musicas" "${icons_folder}/folder-music.svg"
  # other dropbox folders
  set_icon_folder "$HOME/Dropbox/meus_documentos" "${icons_folder}/folder-documents.svg"
  set_icon_folder "$HOME/Dropbox/finanças" "${icons_folder}/folder-green.svg"

  set_icon_all_github_folders
  set_home_hidden_folders
}

validation
set_icon_all_folders

# quit Nautilus to refresh
nautilus -q