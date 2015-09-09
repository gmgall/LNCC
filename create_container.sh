#!/bin/bash

set -e

SHAREDIR="$1"
if [ ! -e "$SHAREDIR" ]; then
	echo "Diretório $SHAREDIR não existente. Criando..."
	mkdir "$SHAREDIR"
	chmod g+s "$SHAREDIR"
fi

CONTAINER_ID=$(docker run -d -P -v $(readlink -f "$SHAREDIR"):/home/rstudio gmgall/test)
echo Porta $(docker inspect --format='{{ (index (index .NetworkSettings.Ports "8787/tcp") 0).HostPort }}' $CONTAINER_ID)
