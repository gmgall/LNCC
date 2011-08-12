#!/bin/bash
#
# mysql-dump.sh - Faz dumps dos bancos de dados MySQL. Usar no crontab.
#
# ??/??/???? - Versão inicial
# por Ricardo <ricardo@lncc.br>
# --
# 28/01/2011 - Adicionado suporte a logging com o syslogd
# 28/01/2011 - Reorganização do código
# por Guilherme <guilherme.gall@ntl.com.br>
# --
# 04/02/2011 - Adicionado suporte a tratamento de sinais
# por Guilherme <guilherme.gall@ntl.com.br>

# -*-*-*- Configuração -*-*-*- 
# Altere as variáveis abaixo para mudar o comportamento do script

# Senha do usuário root no banco
PASS="blablabla"

# Diretório que receberá os dumps
DUMPDIR="/var/spool/dump_mysql"

# Comando que fará os dumps
DUMPCMD="/usr/bin/mysqldump -u root --password="$PASS""

# Arquivo que lista os bancos que devem ser copiados (um banco por linha)
DBLIST="/var/adm/scripts/bancos-mysql"

# Prioridade da mensagem nos logs, ver man syslog p/ mais informações
LOGPRIO="local0.notice"

# -*-*-*- Implementação -*-*-*- 
# Procure alterar o comportamento do script a partir das variáveis acima

DATE=$(date +%Y%m%d-%H:%M:%S)

# Fechando saída de erro
exec 2>&-

# Função que será executada caso o script termine normalmente
exit_ok(){
    logger -t ${0%.sh} -p $LOGPRIO "O backup foi concluído normalmente"
    rm -f /tmp/diff-$$-dump1 /tmp/diff-$$-dump2
    exit 0
}

# Função que será executada caso o script termine com um
# sinal HUP INT QUIT TERM
exit_nok(){
    logger -t ${0%.sh} -p $LOGPRIO "O backup NAO foi concluído normalmente"
    rm -f /tmp/diff-$$-dump1 /tmp/diff-$$-dump2
    trap - EXIT
    exit 2
}

# Setando funções manipuladoras de sinal
trap "exit_ok" EXIT
trap "exit_nok" HUP INT QUIT TERM
    

for DB in $(cat "$DBLIST"); do
    NAME="${DB}-${DATE}.dump"
    $DUMPCMD $DB > "${DUMPDIR%/}"/"$NAME"
    grep -v "Dump completed on" ${DUMPDIR%/}/$DB > /tmp/diff-$$-dump1
    grep -v "Dump completed on" ${DUMPDIR%/}/$NAME > /tmp/diff-$$-dump2
    diff /tmp/diff-$$-dump1 /tmp/diff-$$-dump2 > /dev/null
    if [ $? -eq 1 ]; then
        rm -f "${DUMPDIR%/}"/$DB
        ln -s "${DUMPDIR%/}"/$NAME "${DUMPDIR%/}"/$DB
        logger -t ${0%.sh} -p $LOGPRIO "Feito o dump do banco $DB"
    else
        rm -f "${DUMPDIR%/}"/$NAME
        logger -t ${0%.sh} -p $LOGPRIO "Não foi feito o dump do banco $DB (sem novas alterações)"
    fi
done
