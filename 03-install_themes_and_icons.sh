#!/bin/bash

# ============================================
# Função de debug
# ============================================
function log(){
  echo "[LOG] $*"
}

function init(){
    current_folder=$(pwd)
    ubuntu_version=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d "=" -f2)
    themes_folder="/usr/share/themes"

    # icons folder
    icons_path="$HOME/.local/share/icons/"
    test -d "$icons_path" || mkdir -p "$icons_path"
}

# ============================================
# Function to install Korla Icons
# ============================================
function install_korla_icons(){
    local korla_temp_folder="/tmp/korla_temp"
    # Instala o pacote de ícones 'Korla'
    # ------------------------------------------------------------------
    log "install Korla icon theme"
    [[ -e "${icons_path}/korla" ]] && rm -rf "${icons_path}/korla"
    [[ -e "${icons_path}/korla-light" ]] && rm -rf "${icons_path}/korla-light"

    [[ -e "$korla_temp_folder" ]] || mkdir "$korla_temp_folder" && rm -rf "$korla_temp_folder"
    git clone https://github.com/bikass/korla.git "$korla_temp_folder"
    cd "$korla_temp_folder" && mv korla korla-light "$icons_path"

    # Instala o pacote de folders do 'Korla'
    # o modo de instalação está no github deles.
    log "install Korla icon folder"
    git clone https://github.com/bikass/korla-folders.git
    cd korla-folders
    unzip -x places_1.zip
    mv "places_1" "scalable"
    rm -rf "${icons_path}/korla/places/scalable"
    mv "scalable" "${icons_path}/korla/places"

    rm -rf "$korla_temp_folder"

    log "set icons to Korla"
    gsettings set org.gnome.desktop.interface icon-theme "korla"

    # apply korla icon folders in some folders
    cd "$current_folder"
    bash utils/korla_folders_apply.sh
}

# ============================================
# Install Breeze-Cursor theme
# ============================================
function install_breeze_cursor(){
    sudo apt update
    sudo apt install -y breeze-cursor-theme

    gsettings set org.gnome.desktop.interface cursor-theme "Breeze_Snow"
}

# ============================================
# Install Arc-Dark GTK theme
# ============================================
function _install_arc_dark_theme(){
    # install dependencies
    sudo apt install -y autoconf automake pkg-config libgtk-3-dev gnome-themes-standard gtk2-engines-murrine
    cd ~/bin && git clone https://github.com/horst3180/arc-theme --depth 1 && cd arc-theme
    ./autogen.sh --prefix=/usr
    sudo make install

    # aplica o theme
    gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
    gsettings set org.gnome.shell.extensions.user-theme name "Arc-Dark"
}

# ============================================
# Install Nordic GTK theme
# ============================================
function _install_nordic_theme(){
  git clone https://github.com/EliverLara/Nordic.git ${HOME}/Downloads
  sudo mv ${HOME}/Downloads/*.zip "$themes_folder"
  sudo unzip "${themes_folder}/*.zip"
  sudo rm -rf "${themes_folder}/*.zip"

  # aplica o theme
  gsettings set org.gnome.desktop.interface gtk-theme "Nordic"
  gsettings set org.gnome.desktop.wm.preferences theme "Nordic"
}

# ============================================
# Function that install and apply all GTK themes
# ============================================
function install_gtk_theme(){
  # se for Ubuntu 18.04, instale e aplique o Arc-Dark
  # Se for Ubuntu 20.04, instale e aplique o Nordic
  if [ "$ubuntu_version" == "18.04" ];then
    log "Install Arc-Dark GTK theme..."
    _install_arc_dark_theme
  elif [ "$ubuntu_version" == "20.04" ];then
    log "Install Nordic theme..."
    _install_nordic_theme
  fi

}

# ============================================
# Install Flat-Remix-dark Gnome-Shell theme
# ============================================
function install_FlatRemix_Gnome_Shell(){
  sudo add-apt-repository -y ppa:daniruiz/flat-remix
  sudo apt update
  sudo apt install -y flat-remix-gnome

  gsettings set org.gnome.shell.extensions.user-theme name "Flat-Remix-Dark"
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
log "Inicializing..."
init
log "Install Korla Icons..."
install_korla_icons
log "Install Breeze Cursors..."
install_breeze_cursor

install_gtk_theme

log "Install FlatRemix Gnome-Shell theme..."
install_FlatRemix_Gnome_Shell

refresh_gnome
