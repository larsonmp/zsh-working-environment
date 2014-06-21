#!/usr/bin/env python

import sys
import color #needs ~/.lib in PYTHONPATH

if __name__ == '__main__':
    decoration = color.Decoration()
    for s in decoration.decorations.keys():
        sys.stdout.write(decoration.decorations[s] + ' Decoration: ' + str(s) + decoration.decorations['NONE'] + '\n')
  
    decoration = color.Decoration(['BOLD', 'UNDERLINE', 'BLINK_SLOW'])
    sys.stdout.write(str(decoration) + 'TEST' + decoration.decorations['NONE'] + '\n')
    
    for i in range(30, 38):
        sys.stdout.write('\033[%dm Color: %d\033[0m' % (i, i))
        sys.stdout.write('\033[%dm Color: %d\033[0m\n' % (i + 10, i + 10))
    
    for i in range(90, 98):
        sys.stdout.write('\033[%dm Color: %d\033[0m' % (i, i))
        sys.stdout.write('\033[%dm Color: %d\033[0m\n' % (i + 10, i + 10))

