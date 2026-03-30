#!/usr/bin/env python3
import time
import os

class Profile (object):
    pass

BBC = Profile()
Akaviri = Profile()


BBC.roster_url = "http://win.bbcguild.com/import/"
BBC.guilds = ["bbc1", "bbc2"]
BBC.prefix = "@"
BBC.extended = True

def _get_import_bbc ():
    import_path = os.getenv('IMPORT_PATH', '/app/import')
    return (import_path, "import%s.tsv" % int(time.time()))

BBC.get_import = _get_import_bbc


Akaviri.roster_url = "http://akaviri.com/import/"
Akaviri.guilds = ["union", "exchange", "imports", "etu", "etu2", "imports_whale", "imports_flash", "tse"]

def _get_import_akaviri ():
    import_path = os.getenv('IMPORT_PATH', '/app/import')
    return (import_path, "import%s.tsv" % int(time.time()))

Akaviri.get_import = _get_import_akaviri
Akaviri.prefix = ""
Akaviri.extended = True
