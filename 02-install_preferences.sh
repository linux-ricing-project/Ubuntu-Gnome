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
  if grep -q "^Icon=" /var/lib/AccountsService/users/$USER;then
    sudo sed -i "s|Icon=.*|Icon=${HOME}/.face|g" /var/lib/AccountsService/users/$USER
  else
    sudo echo "Icon=${HOME}/.face" >> /var/lib/AccountsService/users/$USER
  fi
}

# desinstalando o gnome-software (a loja de aplicativo do Ubuntu).
# é..eu não uso ele pra nada mesmo, resolvi desinstalar por padrão
if type gnome-software > /dev/null 2>&1; then
  log "uninstallings the gnome-software..."
  sudo apt remove gnome-software -y
  # remove inclusive o arquivo de 'startup application' que faz ele iniciar no boot.
  test -f /etc/xdg/autostart/gnome-software-service.desktop && sudo rm -rf $_
fi

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

ubuntu_version=$(cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d "=" -f2)
if [ "$ubuntu_version" != "19.04" ];then
  log "Disable Trash icon on Desktop"
  gsettings set org.gnome.nautilus.desktop trash-icon-visible false

  log "Disable Network Servers icon on Desktop"
  gsettings set org.gnome.nautilus.desktop network-icon-visible false

  log "Disable Home folder icon on Desktop"
  gsettings set org.gnome.nautilus.desktop home-icon-visible false

  log "Disable Mounted Volumes icon on Desktop"
  gsettings set org.gnome.nautilus.desktop volumes-visible false
else
  # caso seja o Ubuntu 19.04,ele mudou a forma de exibição dos ícones do Desktop.
  # agora é através de uma 'extension' essa configuração.
  log "Disable Home folder icon on Desktop"
  gsettings set org.gnome.shell.extensions.desktop-icons show-home false
  log "Disable Trash icon on Desktop"
  gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
fi

log "Change control buttons to the left position"
gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'

log "Set favorite-app in Dash"
gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'terminator.desktop', 'spotify.desktop']"

log "Apply clock configs"
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true

log "Apply Nautilus bookmarks"
if [ ! -d "${HOME}/.config/gtk-3.0" ];then
	mkdir -p "${HOME}/.config/gtk-3.0"
fi
cp utils/gnome-settings/bookmarks "${HOME}/.config/gtk-3.0"
sed -i "s/@user@/$(whoami)/g" "${HOME}/.config/gtk-3.0/bookmarks"

# mudando a imagem do profile no GDM
change_gdm_profile

log "Set Wallpaper"
wallpaper_file="wallpaper.jpg"
cp "wallpaper/${wallpaper_file}" "$HOME/Pictures"
gsettings set org.gnome.desktop.background picture-uri file:///home/${USER}/Pictures/${wallpaper_file}

log "Build lock screen wallpaper"
convert /home/${USER}/Pictures/${wallpaper_file} -blur 0x8 /home/${USER}/Pictures/wallpaper_lockscreen.jpg
gsettings set org.gnome.desktop.screensaver picture-uri file:///home/${USER}/Pictures/wallpaper_lockscreen.jpg

gnome-shell --replace &>/dev/null & disown