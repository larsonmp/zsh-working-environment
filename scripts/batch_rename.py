'''
Created on Jun 1, 2011

@author: Micah
'''

import argparse
import glob
import os
import sys
import time

def rename_files(files, verbose=False):
    """Rename \([0-9]{5}\).MTS to %Y-%m-%d_\1.mts (rename the video files from our camcorder)."""
    for file_name in files:
        path = os.path.realpath(file_name)
        mtime = time.localtime(os.stat(path).st_mtime)
        new_name = ('%s_%s' % (time.strftime('%Y-%m-%d', mtime), file_name)).lower()
        new_path = os.path.join(os.path.dirname(path), new_name)
        if verbose:
            print 'renaming "%s" to "%s"' % (file_name, new_name)
        os.rename(path, new_path)

def main():
    parser = argparse.ArgumentParser()
    
    parser.add_argument('files', action='store', nargs='+', help='file(s) to rename')
    parser.add_argument('-V', '--version', action='version', version='%(prog)s 0.1', help='print version')
    parser.add_argument('-v', '--verbose', action='store_true', help='print extra information')
    
    results = parser.parse_args()
    rename_files(results.files, results.verbose)

if __name__ == '__main__':
    main()
