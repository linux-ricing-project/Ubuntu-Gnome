#!/bin/bash

################################################################################
# Description:
#    Script that install all extensions that i use in my gnome
#
################################################################################
# Autor: Frank Junior <frankcbjunior@gmail.com>
# Desde: 02-04-2020
# Versão: 1
################################################################################

# ============================================
# Função de debug
# ============================================
function log(){
  echo "[LOG] $*"
}

# ============================================
# Função de inicialização
# ============================================
function init(){
  gnome_site="https://extensions.gnome.org"

  ubuntu_version=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d "=" -f2)

  # extensions folder
  log "Criando diretório de extensões"
  extensions_path="$HOME/.local/share/gnome-shell/extensions"
  test -d "$extensions_path" || mkdir -p "$extensions_path"

  #  move todos os arquivos de schema para os diretórios locais e compila
  # isso é ncessaŕio principalmente para algumas extebnsões serem configuradas através do gsettings
  log "Criando diretório de schemas"
  local_schema_path="$HOME/.local/share/glib-2.0/schemas/"
  test -d "$local_schema_path" || mkdir -p "$local_schema_path"

  # desabilita todas as extensões
  log "Desabilitando todas as extensões"
  gsettings set org.gnome.shell enabled-extensions "[]"
}

# ============================================
# Função auxiliar, que move todos os arquivos de schemas
# para o diretório $local_schema_path
# ============================================
function _move_schema_files(){
  export XDG_DATA_DIRS=~/.local/share:/usr/share

  find "$extensions_path" -name *gschema.xml -exec ln {} -sfn "$local_schema_path" \;
  glib-compile-schemas "$local_schema_path"
}

# ============================================
# Função auxiliar, que instala genericamente
# qualquer extension individualmente
# Params:
# $1 - URL da extensão
# ============================================
function _install_extension(){
  local extension_url="$1"
  # install all array extensions
  wget -q "$extension_url" -O "get_uuid_file.zip"
  local uuid=$(unzip -c "get_uuid_file.zip" metadata.json | grep uuid | cut -d \" -f4 | grep -v "Archive")
  rm -rf "get_uuid_file.zip"
  # verify if extension already is installed
  if [ ! -d "${extensions_path}/$uuid" ];then
    local json="${gnome_site}/extension-info/?uuid=${uuid}&shell_version=3.22"
    extension_url=${gnome_site}$(curl -s "${json}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/')
    wget --header='Accept-Encoding:none' -O "extensao.zip" "${extension_url}"

    unzip "extensao.zip" -d "$uuid"
    rm -rf "extensao.zip"
    mv "$uuid" "$extensions_path"
  fi

  if [ "$ubuntu_version" == "18.04" ];then
    gnome-shell-extension-tool --enable-extension "$uuid"
  elif [ "$ubuntu_version" == "20.04" ];then
    gnome-extensions enable "$uuid"
  fi
}

# ============================================
# Função que dá refresh no Gnome
# ============================================
function refresh_gnome(){
  # o refresh no Gnome só é necessário no Ubuntu 18.04.
  # No Ubuntu 20.04, ele já dá refresh sozinho
  if [ "$ubuntu_version" == "18.04" ];then
    log "refreshing Gnome..."
    gnome-shell --replace &>/dev/null & disown
  fi
}

# ============================================
# Função que configura a extensão Dash-to-Dock
# ============================================
function configure_dash_to_dock_extensions(){
  log "Apply Dash color"
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-background-color true
  gsettings set org.gnome.shell.extensions.dash-to-dock background-color "#000000"
  gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity "0.9"

  log "Apply Dash indicator style"
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-customize-running-dots true
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-color "#CE5C00"
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-color "#CE5C00"
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-running-dots-border-width 0
  gsettings set org.gnome.shell.extensions.dash-to-dock running-indicator-style "SEGMENTED"

  log "Apply Dash icon size to 20"
  gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 20
  log "Apply Dash always visible"
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
  log "Apply Dash fill all space"
  gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
  gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true

  log "Apply Dash to bottom"
  gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
  log "Apply Dash to intelligent hide"
  gsettings set org.gnome.shell.extensions.dash-to-dock intellihide true
  log "Apply Dash to hide trash icon"
  gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
  log "Apply Dash button to the left"
  gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
}

# ============================================
# Função que configura as outras extensões
# ============================================
function configure_others_extensions(){
  log "Config OpenWeather Extension"
  gsettings set org.gnome.shell.extensions.openweather unit "celsius"
  gsettings set org.gnome.shell.extensions.openweather wind-speed-unit "kph"

  log "Config Apt-Update-Indicator Extension"
  gsettings set org.gnome.shell.extensions.apt-update-indicator update-cmd-options update-manager

  log "Apply Activities-Configurator icon"
  local ubuntu_icon="$(pwd)/ubuntu_icon.svg"
  gsettings set org.gnome.shell.extensions.activities-config activities-config-button-icon-path "$ubuntu_icon"
  gsettings set org.gnome.shell.extensions.activities-config activities-icon-scale-factor 1.8

  log "Apply Activities-Configurator text"
  local ubuntu_description=$(grep "DISTRIB_DESCRIPTION" /etc/lsb-release | cut -d "=" -f2 | sed 's/ LTS//g' | sed 's/"//g')
  gsettings set org.gnome.shell.extensions.activities-config activities-config-button-text "$ubuntu_description"

  log "Apply Activities-Configurator disable hot-corner"
  gsettings set org.gnome.shell.extensions.activities-config activities-config-hot-corner true
}

# ============================================
# Função que instala todas as extensões
# ============================================
function install_all_extensions(){
  extensions=(
    ${gnome_site}/extension-data/dash-to-dockmicxgx.gmail.com.v68.shell-extension.zip
    ${gnome_site}/extension-data/blyryozoon.dev.gmail.com.v7.shell-extension.zip
    ${gnome_site}/extension-data/apt-update-indicator%40franglais125.gmail.com.v20.shell-extension.zip
    ${gnome_site}/extension-data/activities-confignls1729.v84.shell-extension.zip
    ${gnome_site}/extension-data/glassygnomeemiapwil.v17.shell-extension.zip
    ${gnome_site}/extension-data/openweather-extension%40jenslody.de.v97.shell-extension.zip
    ${gnome_site}/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v40.shell-extension.zip
  )

  #  instala todas as extensões
  log "Install all extensions"
  for extension_url in "${extensions[@]}";do
    _install_extension "$extension_url"
  done

  # linka os schemas
  _move_schema_files

  configure_others_extensions
  configure_dash_to_dock_extensions
}

# ============================================
# Main
# ============================================
init
install_all_extensions
refresh_gnome