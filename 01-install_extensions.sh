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
# Função auxiliar, que move todos os arquivos de schemas
# para o diretório $local_schema_path
# ============================================
function _move_schema_files(){
  export XDG_DATA_DIRS=~/.local/share:/usr/share

  find "$extensions_path" -name *gschema.xml -exec ln {} -sfn "$local_schema_path" \;
  glib-compile-schemas "$local_schema_path"
}

# ============================================
# Função auxiliar, que instala genericamente qualquer extension
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

  gnome-shell-extension-tool --enable-extension "$uuid"
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
# Main
# ============================================
gnome_site="https://extensions.gnome.org"

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

# OBS: A extensão Activities-Configurator tava dando problema, depois eu vejo
extensions=(
  ${gnome_site}/extension-data/blyryozoon.dev.gmail.com.v7.shell-extension.zip
  ${gnome_site}/extension-data/apt-update-indicator%40franglais125.gmail.com.v20.shell-extension.zip
  # ${gnome_site}/extension-data/activities-confignls1729.v83.shell-extension.zip
  ${gnome_site}/extension-data/glassygnomeemiapwil.v17.shell-extension.zip
  ${gnome_site}/extension-data/openweather-extension%40jenslody.de.v97.shell-extension.zip
  ${gnome_site}/extension-data/user-themegnome-shell-extensions.gcampax.github.com.v40.shell-extension.zip
)

#  instala todas as extensões
log "Instalando todas as extensões"
for extension_url in "${extensions[@]}";do
  _install_extension "$extension_url"
done

# linka os schemas
_move_schema_files

log "config OpenWeather Extension"
gsettings set org.gnome.shell.extensions.openweather unit "celsius"
gsettings set org.gnome.shell.extensions.openweather wind-speed-unit "kph"

log "config Apt-Update-Indicator Extension"
gsettings set org.gnome.shell.extensions.apt-update-indicator update-cmd-options update-manager

log "Set Dash position do BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM

log "Change Dash icon size to 20"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 20

log "Change 'show apps' button to the left"
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

refresh_gnome