#!/bin/bash

################################################################################
# Description:
#    Script that remove all extensions
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

# desabilita todas as extensões
log "Desabilitando todas as extensões"
gsettings set org.gnome.shell enabled-extensions "[]"

# se existir a pasta de extensions, delete o conteúdo dela
log "Removendo o diretório de extensões"
extensions_path="$HOME/.local/share/gnome-shell/extensions"
test -d "$extensions_path" && rm -rf "$extensions_path"

log "Removendo todos os schemas"
local_schema_path="$HOME/.local/share/glib-2.0/schemas/"
if [ -d "$local_schema_path" ];then
  for schemas in $(find $local_schema_path -type l);do
  rm -rf "$schemas"
  done
fi