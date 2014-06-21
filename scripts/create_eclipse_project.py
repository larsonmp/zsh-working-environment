#!/usr/bin/env python2.7

from glob import glob
from os import environ, unlink as rm
from os.path import basename, expanduser, isdir, join
from re import match, search, sub
from shutil import copy2 as copy, copytree, move
from tempfile import NamedTemporaryFile

def sed(pattern, replacement, path, g=True):
    tmp_file = NamedTemporaryFile(delete=False)
    with open(path, 'r') as fd:
        for line in fd:
            tmp_file.write(sub(pattern, replacement, line))
    tmp_file.close()
    rm(path)
    move(tmp_file.name, path)

def copy_and_filter(file, destination, replacements):
    copy(file, destination)
    for (pattern, replacement) in replacements:
        sed(pattern, replacement, join(destination, basename(file)))

def main():
    vob_root = environ.get('CLEARCASE_ROOT', None)
    if not vob_root:
        raise StandardError('not in a view')
    
    view_tag = basename(vob_root).lower()
    title = view_tag
    if match('espdb[0-9]{8}', view_tag):
        title = 'DR %d' % int(search('(?<=espdb)[0-9]+', view_tag).group(0))
    
    gui_dir = join(vob_root, 'vobs', 'borg101', 'display', 'boa_gui')
    if not isdir(gui_dir):
        raise StandardError('"%s" is not a valid destination' % gui_dir)
    
    for file in glob(expanduser('~/etc/eclipse_project_files/.*')):
        if isdir(file):
            copytree(file, join(gui_dir, basename(file)))
        else:
            copy_and_filter(file, gui_dir, [('%title%', title), ('%view_tag%', view_tag)])

if __name__ == '__main__':
    main()
