#!/usr/bin/env python

import sys

class Foreground:
    def __init__(self, active='WHITE'):
        self.colors = {
            'BLACK':   '\033[30m',
            'RED':     '\033[31m',
            'GREEN':   '\033[32m',
            'YELLOW':  '\033[33m',
            'BLUE':    '\033[34m',
            'MAGENTA': '\033[35m',
            'CYAN':    '\033[36m',
            'WHITE':   '\033[37m'
        }
        self.active = self.colors[active]
    
    def __str__(self):
        return str(active)

    def keys(self):
        return self.colors.keys()

class Background:
    def __init__(self, active='BLACK'):
        self.colors = {
            'BLACK':   '\033[40m',
            'RED':     '\033[41m',
            'GREEN':   '\033[42m',
            'YELLOW':  '\033[43m',
            'BLUE':    '\033[44m',
            'MAGENTA': '\033[45m',
            'CYAN':    '\033[46m',
            'WHITE':   '\033[47m'
        }
        self.active = self.colors[active]
    
    def __str__(self):
        return str(active)

class Decoration:
    """NOTE: decorations can stack."""
    def __init__(self, activeDecorations=[]):
        self.decorations = {
            'NONE':          '\033[0m',
            'BOLD':          '\033[1m',
            'FAINT':         '\033[2m', #unsupported
            'ITALICS':       '\033[3m', #unsupported
            'UNDERLINE':     '\033[4m',
            'BLINK_SLOW':    '\033[5m',
            'BLINK_FAST':    '\033[6m', #unsupported
            'NEGATIVE':      '\033[7m',
            'CONCEAL':       '\033[8m',
            'STRIKETHROUGH': '\033[9m'  #unsupported
        }
        """
        BOLD_OFF:          '\033[22m'
        ITALICS_OFF:       '\033[23m'
        UNDERLINE_OFF:     '\033[24m'
        BLINK_FAST_OFF:    '\033[25m'
        NEGATIVE_OFF:      '\033[27m'
        CONCEAL_OFF:       '\033[28m'
        STRIKETHROUGH_OFF: '\033[29m'
  
        """
        self.active = [self.decorations[x] for x in activeDecorations]
    
    def __str__(self):
        return ''.join(self.active)
    
class Style:
    def __init__(self, bg, fg, d):
        self.foreground = fg
        self.background = bg
        self.decorations = [d]
    
    def setForeground(self, fg=Foreground('BLACK')):
        self.foreground = fg
    
    def setBackground(self, bg=Background('WHITE')):
        self.background = bg
    
    def addDecoration(self, d=Decoration(['NONE'])):
        self.decorations.append(d)
    
    def reset(self):
        self.foreground = Foreground('NONE')
        self.background = Background('NONE')
        self.decorations = []
    

class Output:
    def __init__(self):
        pass
    
    def write(self, out=sys.stdout, decoration=None, bg=None, fg=None, text=None):
        pass

class Input:
    def strip(self, text=None):
        """Strips color/decoration from string."""
        return text


if __name__ == '__main__':
    decoration = Decoration()
    for s in decoration.decorations.keys():
        sys.stdout.write(decoration.decorations[s] + ' Decoration: ' + str(s) + decoration.decorations['NONE'] + '\n')
    
    decoration = Decoration(['BOLD', 'UNDERLINE', 'BLINK_SLOW'])
    sys.stdout.write(str(decoration) + 'TEST' + decoration.decorations['NONE'] + '\n')
    
    for i in range(30, 38):
        sys.stdout.write('\033[%dm Color: %3d \033[0m' % (i, i))
        sys.stdout.write('\033[%dm Color: %3d \033[0m\n' % (i + 10, i + 10))
    
    for i in range(90, 98):
        sys.stdout.write('\033[%dm Color: %3d \033[0m' % (i, i))
        sys.stdout.write('\033[%dm Color: %3d \033[0m\n' % (i + 10, i + 10))

