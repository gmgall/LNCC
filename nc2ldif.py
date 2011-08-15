#!/usr/bin/env python
# coding: utf-8
#
# nc2ldif.py - Gera arquivo LDIF para o servidor LDAP do LNCC
# usando como entrada um dump em CSV da base "contatos" e a base
# passwd (unshadowed) da nisserver
#
# por Guilherme Magalhães Gall	<guilherme.gall@ntl.com.br>
#				<gmgall@gmail.com>
#
# 09/08/2011 - Versão inicial
# 15/08/2011 - Adicionada verificação básica do formato dos arquivos

class FormatError(Exception):
	pass

class LDIFSpitter:

    def __init__(self, passwd, csv):
        self.dct = {}
        self.passwd = open(passwd, 'r')
        self.csv = open(csv, 'r')

    def merge_data(self):
	import re
        with self.passwd as f:
            for line in f:
		if re.match('^\w+:.*:(\d+:){2}[\wãẽĩõũ, ]*:/[^:]*:/[^:]*$', line, flags=re.LOCALE):
			arr = line.strip().split(':')
			self.dct[arr[0]] = arr[1:]
		else:
			raise FormatError('O passwd não está com o formato correto')

        with self.csv as f:
            for line in f:
                arr = line.split(';')
		if len(arr) != 44:
			raise FormatError('O csv não está com o formato correto')
                # coordenação
                coord = arr[14].split(' ')[0]
                coord = 'EXT' if arr[22] == 'Externo' else coord
                self.dct[arr[17]].append(coord)
                # title
                self.dct[arr[17]].append(arr[22])
                # ramal
                ramal = arr[13]
                ramal = '0000' if not ramal else ramal
                self.dct[arr[17]].append(ramal)
                # e-mail
                self.dct[arr[17]].append(arr[18])

        return self.dct

    def spit(self):

        for login, info in self.merge_data().iteritems():
            print "dn: uid=%s,ou=%s,dc=lncc,dc=br" %(login, info[6])
            print "objectClass: inetOrgPerson"
            print "objectClass: person"
            print "objectClass: posixAccount"
            print "objectClass: top"
            print "objectClass: shadowAccount"
            print "cn: %s" %(info[3])
            print "givenName: %s" %(info[3].split(' ')[0])
            print "sn: %s" %(info[3].split(' ')[-1])
            print "gidNumber: %s" %(info[2])
            print "homeDirectory: %s" %(info[4])
            print "ou: %s" %(info[6])
            print "title: %s" %(info[7])
            print "telephoneNumber: %s" %(info[8])
            print "uid: %s" %(login)
            print "uidNumber: %s" %(info[1])
            print "gecos: %s" %(rem_acentuacao(info[3]))
            print "loginShell: %s" %(info[5])
            print "mail: %s" %(info[-1])
            print "shadowLastChange: 15104"
            print "shadowMax: 99999"
            print "shadowWarning: 7"
            print "userPassword: {crypt}%s" %(info[0])
            print

def rem_acentuacao(str):
	from unicodedata import normalize
	return normalize('NFKD', str.decode('utf-8')).encode('ASCII', 'ignore')

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 3:
        print "Uso: %s PASSWD CSV" %(sys.argv[0])
        sys.exit(1)
    try:
        d = LDIFSpitter(sys.argv[1], sys.argv[2])
        d.spit()
    except IOError as e:
        if e.errno == 2:
            print "Arquivo %s não encontrado" %(e.filename)
        elif e.errno == 13:
            print "Permissão negada para abrir %s" %(e.filename)
        sys.exit(2)
    except FormatError as e:
	print e
	sys.exit(3)
