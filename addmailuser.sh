#!/bin/bash
#
# addmailuser.sh - Cria Maildir do usuário dentro de seu HOME
#
# ??/??/???? - Versão inicial
# por Ricardo <ricardo@lncc.br>
# --
# 22/06/2011 - Trocado ypcat | grep por getent na consulta do registro
# 22/06/2011 - Adicionadas verificações:	-da existência do Maildir
#						-da existência do usuário
# 22/06/2011 - BUGFIX: Corrigida chamada ao maildirmake.dovecot
# 22/06/2011 - Códigos de retorno agora são usados
# por Guilherme <guilherme.gall@ntl.com.br>
# 29/06/2011 - BUGFIX: Atribui permissões corretas ao home do usuário
# por Guilherme <guilherme.gall@ntl.com.br>

if [ $# -ne 1 ]; then
   echo "Uso: $0 login"
   exit
fi

registro=$(getent passwd $1)
if [ -z "$registro" ]; then
	echo "Usuário $1 não encontrado"
	exit 1
fi

IFS=:
set $registro

nome="$1"
home="$6"
grupo="$4"

if [ -d "$home/Maildir" ]; then
  echo "$home/Maildir já existe"
  exit 2
fi

# Tenta criar Maildir do usuário. Se for bem sucedido muda as
# permissões do HOME do usuário para USUÁRIO:GRUPO_PADRÃO, se
# for mal sucedido, sai com código de retorno 3.

# Não foi modificado o script maildirmake.dovecot porque ele
# veio no pacote dovecot-common e as alterações seriam perdidas
# no momento de uma atualização do pacote.

# XXX Se nada após os dois pontos for usado o grupo é o padrão.
# XXX man chown para mais informações.
maildirmake.dovecot "$home/Maildir" "$nome" && chown -R "$nome": "$home" || exit 3
