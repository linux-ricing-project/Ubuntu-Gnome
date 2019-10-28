#!/bin/bash

################################################################################
# Descrição:
#    Script que aplica as minhas customizações do GNOME
#
################################################################################
# Uso:
#    ./gnome_look.sh --help
#       - exibe mensagem de ajuda.
#
#    ./gnome_look.sh --<nome_do_look>
#       - aplica a customização de acordo com cada look.
#
# Looks disponíveis:
#   --caruaru
#
################################################################################
# Dependencias:
# figlet --> exibe mensagem de banner (em ASCII)
# instalação: 'sudo apt-get install figlet'
################################################################################
# Autor: Frank Junior <frankcbjunior@gmail.com>
# Desde: 29-04-2019
# Versão: 1
################################################################################


################################################################################
# Configurações
# set:
# -e: se encontrar algum erro, termina a execução imediatamente
  set -e


################################################################################
# Variáveis - todas as variáveis ficam aqui

gnome_look="$1"
gnome_site="https://extensions.gnome.org"

  # mensagem de help
    nome_do_script=$(basename "$0")

    mensagem_help="
  Uso: $nome_do_script [OPÇÕES] <NOME_DO_SCRIPT>

  Descrição: .....

  OPÇÕES: - opcionais
    -h, --help  Mostra essa mesma tela de ajuda

  PARAM - obrigatório
    - descrição do PARAM

  Ex.: ./$nome_do_script -h
  Ex.: ./$nome_do_script PARAM
  "


################################################################################
# Utils - funções de utilidades

  # códigos de retorno
  # [condig-style] constantes devem começar com 'readonly'
  readonly SUCESSO=0
  readonly ERRO=1

  # debug = 0, desligado
  # debug = 1, ligado
  debug=0

  # ============================================
  # Função pra imprimir informação
  # ============================================
  _print_info(){
    local amarelo="$(tput setaf 3 2>/dev/null || echo '\e[0;33m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${amarelo}$1${reset}\n"
  }

  # ============================================
  # Função pra imprimir mensagem de sucesso
  # ============================================
  _print_success(){
    local verde="$(tput setaf 2 2>/dev/null || echo '\e[0;32m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${verde}$1${reset}\n"
  }

  # ============================================
  # Função pra imprimir erros
  # ============================================
  _print_error(){
    local vermelho="$(tput setaf 1 2>/dev/null || echo '\e[0;31m')"
    local reset="$(tput sgr 0 2>/dev/null || echo '\e[0m')"

    printf "${vermelho}[ERROR] $1${reset}\n"
  }

  # ============================================
  # Função de debug
  # ============================================
  _debug_log(){
    if [ "$debug" = 1 ];then
       _print_info "[DEBUG] $*"
    fi
}

  # ============================================
  # tratamento das exceções de interrupções
  # ============================================
  _exception(){
    return "$ERRO"
  }

  # ============================================
  # Verificar se um pacote está instalado
  # $1 --> nome do pacote que deseja verificar
  # $2 --> mensagem de erro customizada (OPCIONAL)
  # ============================================
  _die(){
    local package=$1
    local custom_msg=$2

    if ! type $package > /dev/null 2>&1; then
      _print_error "$package is not installed"
      test ! -z "$custom_msg" && _print_error "$custom_msg"
      exit $ERRO
    fi
  }

################################################################################
# Validações - regras de negocio até parametros

  # ============================================
  # tratamento de validacoes
  # ============================================
  validacoes(){
    # verifica se o "gnome-shell" está instalado. Se não estiver, o script retorna erro.
    _die "gnome-shell" "This script only works on gnome-shell"

    # verifica o parametro passado pro script com o "looks" disponíveis pro Gnome
    if [ -z "$gnome_look" ];then
      _print_error "Type the look name in script param"
      exit "$ERRO"
    fi

    #  instalando a dependencias do "figlet" (para exibição de banners)
    if ! type figlet > /dev/null 2>&1; then
      _print_info "instalando dependencias"
      sudo apt install -y figlet
      clear
    fi
  }

################################################################################
# Funções do Script - funções próprias e específicas do script

  # ============================================
  # Função auxiliar que save as configurações default do GNOME
  # ============================================
  _save_reset_settings(){
    if [ ! -e "$reset_settings_file" ];then
      # save default Dash position
      local dock_position_value=$(gsettings get org.gnome.shell.extensions.dash-to-dock dock-position)
      echo "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position $dock_position_value" > "$reset_settings_file"

      # save default Dash icon size
      local dash_max_icon_size_value=$(gsettings get org.gnome.shell.extensions.dash-to-dock dash-max-icon-size)
      echo "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size $dash_max_icon_size_value" >> "$reset_settings_file"

      # save default 'show apps' button
      local show_apps_at_top_value=$(gsettings get org.gnome.shell.extensions.dash-to-dock show-apps-at-top)
      echo "gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top $show_apps_at_top_value" >> "$reset_settings_file"

      # save default default wallpaper
      local background_value=$(gsettings get org.gnome.desktop.background picture-uri)
      echo "gsettings set org.gnome.desktop.background picture-uri $background_value" >> "$reset_settings_file"

      # save default screensaver
      local screensaver_value=$(gsettings get org.gnome.desktop.screensaver picture-uri)
      echo "gsettings set org.gnome.desktop.screensaver picture-uri $screensaver_value" >> "$reset_settings_file"

      # save default cursor
      local cursor_theme_value=$(gsettings get org.gnome.desktop.interface cursor-theme)
      echo "gsettings set org.gnome.desktop.interface cursor-theme $cursor_theme_value" >> "$reset_settings_file"

      # save default icon-theme
      local icon_theme_value=$(gsettings get org.gnome.desktop.interface icon-theme)
      echo "gsettings set org.gnome.desktop.interface icon-theme $icon_theme_value" >> "$reset_settings_file"

      # save default gtk-theme
      local gtk_theme_value=$(gsettings get org.gnome.desktop.interface gtk-theme)
      echo "gsettings set org.gnome.desktop.interface gtk-theme $gtk_theme_value" >> "$reset_settings_file"

      # save default power configs
      local lid_close_battery_action_value=$(gsettings get org.gnome.settings-daemon.plugins.power lid-close-battery-action)
      echo "gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action $lid_close_battery_action_value" >> "$reset_settings_file"

      local lid_close_ac_action_value=$(gsettings get org.gnome.settings-daemon.plugins.power lid-close-ac-action)
      echo "gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action $lid_close_ac_action_value" >> "$reset_settings_file"

    fi
  }

  # ============================================
  # Função que inicializa o script,
  # criando os diretórios necessários
  # ============================================
  init(){
    _print_info "initializing..."
    # extensions folder
    extensions_path="$HOME/.local/share/gnome-shell/extensions"
    test -d "$extensions_path" || mkdir -p "$extensions_path"

    # icons folder
    icons_path="$HOME/.local/share/icons/"
    test -d "$icons_path" || mkdir -p "$icons_path"

    # criando o diretório de configuração do script.
    gnome_look_config_folder="$HOME/.config/gnome_look"
    reset_settings_file="$gnome_look_config_folder/gsettings_reset_backup.txt"
    test -d "$gnome_look_config_folder" || {
      mkdir -p "$gnome_look_config_folder"
      _save_reset_settings
      }

    #  move todos os arquivos de schema para os diretórios locais e compila
    # isso é ncessaŕio principalmente para o "Openweather" ser configurado através do gsettings
    local_schema_path="$HOME/.local/share/glib-2.0/schemas/"
    test -d "$local_schema_path" || mkdir -p "$local_schema_path"
  }

  # ============================================
  # Função base, com configurações genéricas de looks,
  # onde todos os looks utilizarão.
  # ============================================
  base(){
    clear
    figlet "Base Theme"

    # desabilita todas as extensões
    gsettings set org.gnome.shell enabled-extensions "[]"

    # exibindo todos os pacotes que são carregados no boot.
    # (através dessa linha, dá pra gerenciar melhor usando o 'Startup Applications')
    if grep -q -r "NoDisplay=true" /etc/xdg/autostart/*.desktop; then
      echo "showing all the startup applicaitons..."
      sudo sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop
    fi

    # desinstalando o gnome-software (a loja de aplicativo do Ubuntu).
    # é..eu não uso ele pra nada mesmo, resolvi desinstalar por padrão
    if type gnome-software > /dev/null 2>&1; then
      echo "uninstallings the gnome-software..."
      sudo apt remove gnome-software -y
      # remove inclusive o arquivo de 'startup application' que faz ele iniciar no boot.
      test -f /etc/xdg/autostart/gnome-software-service.desktop && sudo rm -rf $_
    fi

    # se existir o arquivo 'gnome-welcome-tour.desktop'
    # significa dizer que aquela janela de 'welcome' é carregada no boot.
    # desabilite ela, criando um arquivo .desktop novo lá em ~/.config/autostart dessa forma.
    test -f /etc/xdg/autostart/gnome-welcome-tour.desktop && (
      echo -e '[Desktop Entry]\nHidden=true' > ~/.config/autostart/gnome-welcome-tour.desktop
    )

    # instalando a extensão "Unite". Dentre as coisas que ela faz é
    # 1. levar o relógio pro lado direito, e esconder o botão "activities"
    # ------------------------------------------------------------------
    local unite_extension_name="unite-shell-v31"
    local unit_uuid="unite@hardpixel.eu"
    if [ ! -d "${extensions_path}/${unit_uuid}" ];then
      cd "$extensions_path"
      wget "https://github.com/hardpixel/unite-shell/releases/download/v31/${unite_extension_name}.zip"
      unzip -x "${unite_extension_name}.zip"
      rm -rf "${unite_extension_name}.zip"
      cd -
    fi

    gnome-shell-extension-tool --enable-extension "$unit_uuid"
    # ------------------------------------------------------------------

    extensions=(
      # instala a extensão de exibição do status de tempo/clima
      ${gnome_site}/extension-data/openweather-extension%40jenslody.de.v97.shell-extension.zip
    )

    #  instala todas as extensões
    for extension_url in "${extensions[@]}";do
      _install_extension "$extension_url"
    done

    # linka os schemas
    _move_schema_files

    echo "applying power config preferences"
    gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action "nothing"
    gsettings set org.gnome.settings-daemon.plugins.power lid-close-ac-action "nothing"

    echo "config OpenWeather Extension"
    gsettings set org.gnome.shell.extensions.openweather unit "celsius"
    gsettings set org.gnome.shell.extensions.openweather wind-speed-unit "kph"

    echo "config Unite Extension"
    gsettings set org.gnome.shell.extensions.unite desktop-name-text "Ubuntu"

    if [ "$ubuntu_version" != "19.04" ];then
      echo "Disable Trash icon on Desktop"
      gsettings set org.gnome.nautilus.desktop trash-icon-visible false

      echo "Disable Network Servers icon on Desktop"
      gsettings set org.gnome.nautilus.desktop network-icon-visible false

      echo "Disable Home folder icon on Desktop"
      gsettings set org.gnome.nautilus.desktop home-icon-visible false

      echo "Disable Mounted Volumes icon on Desktop"
      gsettings set org.gnome.nautilus.desktop volumes-visible false
    else
      # caso seja o Ubuntu 19.04,ele mudou a forma de exibição dos ícones do Desktop.
      # agora é através de uma 'extension' essa configuração.
      echo "Disable Home folder icon on Desktop"
      gsettings set org.gnome.shell.extensions.desktop-icons show-home false
      echo "Disable Trash icon on Desktop"
      gsettings set org.gnome.shell.extensions.desktop-icons show-trash false
    fi

    echo "Change control buttons to the left position"
    gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'
  }

  # ============================================
  # Função auxiliar, que move todos os arquivos de schemas
  # para o diretório $local_schema_path
  # ============================================
  _move_schema_files(){
    export XDG_DATA_DIRS=~/.local/share:/usr/share

    find "$extensions_path" -name *gschema.xml -exec ln {} -sfn "$local_schema_path" \;
    glib-compile-schemas "$local_schema_path"
  }

  # ============================================
  # Função auxiliar, que instala genericamente qualquer extension
  # ============================================
  _install_extension(){
    local extension_url="$1"
    # install all array extensions
    wget -q "$extension_url" -O "get_uuid_file.zip"
    uuid=$(unzip -c "get_uuid_file.zip" metadata.json | grep uuid | cut -d \" -f4 | grep -v "Archive")
    rm -rf "get_uuid_file.zip"
    # verify if extension already is installed
    if [ ! -d "${extensions_path}/$uuid" ];then
      json="${gnome_site}/extension-info/?uuid=${uuid}&shell_version=3.22"
      extension_url=${gnome_site}$(curl -s "${json}" | sed -e 's/^.*download_url[\": ]*\([^\"]*\).*$/\1/')
      wget --header='Accept-Encoding:none' -O "extensao.zip" "${extension_url}"

      unzip "extensao.zip" -d "$uuid"
      rm -rf "extensao.zip"
      mv "$uuid" "$extensions_path"
    fi

    gnome-shell-extension-tool --enable-extension "$uuid"
  }

  # ============================================
  # Função de reset, volta as configurações padrões do Gnome
  # ============================================
  reset_look(){
    # banner
    clear
    figlet "Reset Theme"

    # desabilita todas as extensões
    gsettings set org.gnome.shell enabled-extensions "[]"

    # se o arquivo de reset_settings existir, aplique ele
    if [ -e "$reset_settings_file" ];then
      bash -x "$reset_settings_file"
      gnome-shell --replace &>/dev/null & disown
    fi

    # se existir a pasta de icones, delete
    [[ -e "$icons_path" ]] && rm -rf "$icons_path"

    # se existir a pasta de extensions, delete o conteúdo dela
    [[ -e "$extensions_path" ]] && rm -rf "${extensions_path}/*"

    _print_info "OK"
  }

  # ============================================
  # Função que aplica o look chamado "caruaru"
  # ============================================
  caruaru_look(){
    # banner
    clear
    figlet "Caruaru Theme"

    # Install Adapta Theme
    if [ ! -d "/usr/share/themes/Adapta" ];then
      sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B76E53652D87398A
      sudo apt-get update
      sudo apt-get install -y adapta-gtk-theme
    fi

    # Instala o pacote de ícones 'Korla'
    # ------------------------------------------------------------------
    echo "install Korla icon theme"
    [[ -e "${icons_path}/korla" ]] && rm -rf "${icons_path}/korla"
    [[ -e "${icons_path}/korla-light" ]] && rm -rf "${icons_path}/korla-light"

    local current_folder=$(pwd)
    [[ -e .temp_dir ]] || mkdir .temp_dir && rm -rf .temp_dir
    git clone https://github.com/bikass/korla.git .temp_dir
    cd .temp_dir && mv korla korla-light "$icons_path"

    # Instala o pacote de fodlers do 'Korla'
    # o modo de instalação está no github deles.
    echo "install Korla icon folder"
    git clone https://github.com/bikass/korla-folders.git
    cd korla-folders
    unzip -x places_1.zip
    mv "places_1" "scalable"
    rm -rf "${icons_path}/korla/places/scalable"
    mv "scalable" "${icons_path}/korla/places"

    cd "$current_folder"
    rm -rf .temp_dir
    # ------------------------------------------------------------------

    _print_info "Applying gnome settings"

    echo "Set Dash position do BOTTOM"
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM

    echo "Change Dash icon size to 20"
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 20

    echo "Change 'show apps' button to the left"
    gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

    echo "Set favorite-app in Dash"
    gsettings set org.gnome.shell favorite-apps "['org.gnome.Nautilus.desktop', 'google-chrome.desktop', 'terminator.desktop', 'spotify.desktop']"

    echo "Set Wallpaper"
    local wallpaper_file="caruaru_look_wallpaper.jpg"
    cp "wallpaper/${wallpaper_file}" "$HOME/Pictures"
    gsettings set org.gnome.desktop.background picture-uri file:///home/${USER}/Pictures/${wallpaper_file}

    echo "Build lock screen wallpaper"
    convert /home/${USER}/Pictures/${wallpaper_file} -blur 0x8 /home/${USER}/Pictures/wallpaper_lockscreen.jpg
    gsettings set org.gnome.desktop.screensaver picture-uri file:///home/${USER}/Pictures/wallpaper_lockscreen.jpg

    echo "set icons to Korla"
    gsettings set org.gnome.desktop.interface icon-theme "korla"

    echo "set Adapta Theme"
    gsettings set org.gnome.desktop.interface gtk-theme "Adapta-Nokto"

    echo "restart Gnome"
    gnome-shell --replace &>/dev/null & disown
    _print_info "OK"
  }

  # ============================================
  # Função Main
  # ============================================
  main(){

    local ubuntu_version=$(cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d "=" -f2)
    init

    case "$gnome_look" in
      --caruaru)
        base
          caruaru_look
      ;;
      --olinda)
        echo "olinda not implemented yet"
      ;;
      --reset)
        reset_look
      ;;
      *) _print_info "select one option" ;;
    esac
  }

  # ============================================
  # Função que exibe o help
  # ============================================
  verifyHelp(){
    case "$1" in

      # mensagem de help
      -h | --help)
        _print_info "$mensagem_help"
        exit "$SUCESSO"
      ;;

    esac
  }

################################################################################
# Main - execução do script

  # trata interrrupção do script em casos de ctrl + c (SIGINT) e kill (SIGTERM)
  trap _exception SIGINT SIGTERM
  verifyHelp "$1"
  validacoes
  main "$1"

################################################################################
# FIM do Script =D
