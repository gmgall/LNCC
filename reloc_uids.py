#!/usr/bin/env python
# coding: utf-8
#
# reloc_uids.py - Relocates UIDs based in a interval of invalid UIDs
# and in a base UID for relocation. Tested in Ubuntu Linux 12.04.
#
# Use: reloc_uids.py lower higher base | bash
#
# by Guilherme Magalhães Gall   <guilherme.gall@ntl.com.br>
#                               <gmgall@gmail.com>
#
# 03/07/2011 - Initial version


import pwd
import itertools
import argparse

def get_inadequate_users(lower, higher):
    if lower >= higher:
        raise ValueError('Invalid interval informed: %d-%d' %(lower, higher))
    entries = [entry for entry in pwd.getpwall() if entry.pw_uid >= lower
            and entry.pw_uid <= higher]
    return list(set(entries))

def next_free_UID_generator(base):
    it = itertools.count(base)
    for uid in it:
        try:
            pwd.getpwuid(uid)
        except KeyError:
            yield uid

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='''Relocates UIDs based in a interval of invalid UIDs and in a base UID for relocation.''')
    parser.add_argument('lower', type=int, help='lower limit for invalid UID')
    parser.add_argument('higher', type=int, help='higher limit for invalid UID')
    parser.add_argument('base', type=int, help='base for relocation')
    args = parser.parse_args()

    gen = next_free_UID_generator(args.base)
    try:
        for user in get_inadequate_users(args.lower, args.higher):
            new_uid = gen.next()
            print "usermod -u %d %s" %(new_uid, user.pw_name)
    except ValueError:
        parser.print_help()
