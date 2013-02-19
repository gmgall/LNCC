#!/bin/bash
#
# prj_bkp.sh - Faz rsync do volume DRBD que mantém os Maildirs dos
# usuários para um volume num storage externo, montado via NFS.
# Verifica se os volumes estão montados antes de prosseguir, se não
# estiverem, envia um e-mail reportando falha. Usar no crontab.
#
# 19/02/2013 - Versão inicial
# por Guilherme <gmgall@lncc.br>

# -*-*-*- Configuração -*-*-*-
# Altere as variáveis abaixo para mudar o comportamento do script

# Volume com os Maildirs dos usuários
VOLLOCAL="/prj/"

# Volume que deve ser montado via NFS e receberá o backup
VOLNFS="/prj_bkp/"

# Mensagem enviada por e-mail em caso de falha no backup
MSG="Não foi possível fazer o backup de $VOLLOCAL em $VOLNFS.
Seguem filesystems disponíveis:

$(df -hT)"

# Endereço de e-mail que deve receber notificação de falha
EMAIL="user@domain"

# -*-*-*- Implementação -*-*-*-
# Procure alterar o comportamento do script a partir das variáveis acima

# O comando mountpoint testa se determinado diretório é um ponto de montagem
# Se o mountpoint não estiver disponível, poderia ser utilizada a função
#
#	 test_if_mounted(){ 
#		df "$1" | grep -q "$1"
#	 }


if mountpoint -q "$VOLLOCAL" && mountpoint -q "$VOLNFS"; then
	rsync -a --exclude='.snapshot' --exclude='nitrio' --delete "$VOLLOCAL" "$VOLNFS"
else
	echo "$MSG" | mail -s "Falha em backup da iota" "$EMAIL"
	exit 1
fi
