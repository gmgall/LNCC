#!/bin/bash
#
# createcontainer.sh - Cria um container docker a partir da imagem
# gmgall/docker-rstudio que monta o diretório passado por parâmetro
# como homedir do usuário rstudio.
#
# 09/09/2015 - Versão inicial
# por Guilherme <gmgall@lncc.br>

set -e

IMAGE="gmgall/docker-rstudio"

SHAREDIR="$1"

if [ ! "$SHAREDIR" ]; then
	echo "Informe um diretório para ser o homedir do usuário rstudio" >&2
	exit 1
fi

if [ ! -e "$SHAREDIR" ]; then
	echo "Diretório $SHAREDIR não existente. Criando..."
	mkdir "$SHAREDIR"
	chmod g+s "$SHAREDIR"
fi

CONTAINER_ID=$(docker run -d -P -v $(readlink -f "$SHAREDIR"):/home/rstudio "$IMAGE")
PORT=$(docker inspect --format='{{ (index (index .NetworkSettings.Ports "8787/tcp") 0).HostPort }}' $CONTAINER_ID)

echo "Acesse o container em $(hostname -f):$PORT"
echo "O homedir do usuário rstudio está montado em $SHAREDIR"
