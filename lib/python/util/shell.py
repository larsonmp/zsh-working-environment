import os
import pprint
import sys

def calculate(operation):
    """Perform basic arithmetic operations."""
    print eval(str(operation))

def print_email():
    """Prints my (Micah's) e-mail address.  This function is preserved solely for its obnoxiousness."""
    print '@'.join(['.'.join([w[::-1] for w in p.split('.')]) for p in 'hacim.nosral,cgn.moc'.split(',')])

def print_env():
    """Prints all variables in the environment table."""
    pprint.pprint(dict(os.environ))

def print_error(codes):
    """Print the error messages associated with the elements in codes."""
    print '\n'.join(['%s: %s' % (code, os.strerror(int(code))) for code in codes])

def print_unicode(values):
    """Print the unicode characters in values."""
    print ' '.join([unichr(int(x)) for x in values])

def main(args):
    {
        'calculate': lambda: calculate(' '.join(args[1:])),
        'pemail':    lambda: print_email(),
        'penv':      lambda: print_env(),
        'perror':    lambda: print_error(args[1:]),
        'puni':      lambda: print_unicode(args[1:])
    }[args[0]]()

if __name__ == '__main__':
    main(sys.argv[1:])
