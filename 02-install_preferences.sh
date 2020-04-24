#!/bin/bash

################################################################################
# Description:
#    Script that configure my preferences in Gnome
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
# Função que muda a imagem do perfil no GDM
# ============================================
function change_gdm_profile(){
  log "Copy profile picture"
  cp utils/profile.png ${HOME}/.face

  log "Change profile picture"
  if sudo grep -q "^Icon=" /var/lib/AccountsService/users/$USER;then
    sudo sed -i "s|Icon=.*|Icon=${HOME}/.face|g" /var/lib/AccountsService/users/$USER
  else
    sudo bash -c "echo \"Icon=${HOME}/.face\" >> /var/lib/AccountsService/users/$USER"
  fi
}

# ============================================
# Função que desinstala os softwares que eu não uso
# ============================================
function uninstall_unused_softwares(){
  # desinstalando o gnome-software (a loja de aplicativo do Ubuntu).
  # é..eu não uso ele pra nada mesmo, resolvi desinstalar por padrão
  if type gnome-software > /dev/null 2>&1; then
    log "uninstallings the gnome-software..."
    sudo apt remove gnome-software -y
    # remove inclusive o arquivo de 'startup application' que faz ele iniciar no boot.
    test -f /etc/xdg/autostart/gnome-software-service.desktop && sudo rm -rf $_
  fi

}

# ============================================
# Função que muda o wallpaper
# ============================================
function change_wallpaper(){
  log "Set Wallpaper"
  wallpaper_file="wallpaper.jpg"
  cp "wallpaper/${wallpaper_file}" "$HOME/Pictures"
  gsettings set org.gnome.desktop.background picture-uri file:///home/${USER}/Pictures/${wallpaper_file}


  # Mudar a lock screen, só é ncessário no Ubuntu 18.04
  # No Ubuntu 20.04, ele já seta essa lockScreen + Blur por default
  if [ "$ubuntu_version" == "18.04" ];then
    log "Build lock screen wallpaper"
    convert /home/${USER}/Pictures/${wallpaper_file} -blur 0x8 /home/${USER}/Pictures/wallpaper_lockscreen.jpg
    gsettings set org.gnome.desktop.screensaver picture-uri file:///home/${USER}/Pictures/wallpaper_lockscreen.jpg
  fi
}

# ============================================
# Função que aplica minhas preferencias de configurações
# ============================================
function apply_config_preferences(){
  # exibindo todos os pacotes que são carregados no boot.
  # (através dessa linha, dá pra gerenciar melhor usando o 'Startup Applications')
  if grep -q -r "NoDisplay=true" /etc/xdg/autostart/*.desktop; then
    log "showing all the startup applications..."
    sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
  fi

  # se existir o arquivo 'gnome-welcome-tour.desktop'
  # significa dizer que aquela janela de 'welcome' é carregada no boot.
  # desabilite ela, criando um arquivo .desktop novo lá em ~/.config/autostart dessa forma.
  test -f /etc/xdg/autostart/gnome-welcome-tour.desktop && (
    echo -e '[Desktop Entry]\nHidden=true' > ~/.config/autostart/gnome-welcome-tour.desktop
  )

  log "applying power and keyboard config preferences"
  dconf load /org/gnome/settings-daemon/plugins/ < utils/gnome-settings/keyboard-shortcuts-gnome.dconf

  log "Disable Home folder icon on Desktop"
  gsettings set org.gnome.shell.extensions.desktop-icons show-home false
  log "Disable Trash icon on Desktop"
  gsettings set org.gnome.shell.extensions.desktop-icons show-trash false

  log "Change control buttons to the left position"
  gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

  log "Set favorite-app in Dash"
  gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'terminator.desktop', 'spotify.desktop']"

  log "Apply clock configs"
  gsettings set org.gnome.desktop.interface clock-show-date true
  gsettings set org.gnome.desktop.interface clock-show-seconds true
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
  cd "$current_folder"
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
# Função aplica os favoritos no Nautilus
# ============================================
function apply_nautilus_bookmarks(){
  log "Apply Nautilus bookmarks"
  if [ ! -d "${HOME}/.config/gtk-3.0" ];then
    mkdir -p "${HOME}/.config/gtk-3.0"
  fi
  cp utils/gnome-settings/bookmarks "${HOME}/.config/gtk-3.0"
  sed -i "s/@user@/$(whoami)/g" "${HOME}/.config/gtk-3.0/bookmarks"
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
ubuntu_version=$(grep "DISTRIB_RELEASE" /etc/lsb-release | cut -d "=" -f2)

uninstall_unused_softwares
apply_config_preferences
configure_dash_to_dock_extensions
configure_others_extensions
apply_nautilus_bookmarks
change_gdm_profile
change_wallpaper
refresh_gnome