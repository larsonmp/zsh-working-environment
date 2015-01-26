import math
from numpy import percentile
import random

def upper_power_of_two(number):
    """Return the next power of two."""
    return int(2 ** math.ceil(math.log(number, 2)))

def shuffle(array):
    """Shuffle a list in-place. Algorithm courtesy of Fisher, Yates, Durstenfeld, and Knuth."""
    for i in reversed(range(1, len(array))):
        r = random.randint(0, i)
        array[i], array[r] = array[r], array[i]

def gcd(a, b):
    """Return the greatest common denominator of inputs a and b."""
    a, b = abs(a), abs(b)
    while a:
        a, b = b % a, a
    return b

def lcm(a, b):
    """Return the least common multiple of inputs a and b."""
    return a * b // gcd(a, b)

def factorial(n):
    """Return n! (factorial function not added to python until v2.6)."""
    return reduce(lambda a, b: a * b, xrange(2, n + 1))
    #bonus: factorial = lambda x: reduce(lambda a, b: a * b, xrange(2, x + 1))

def mean(lst):
    return sum(lst) / len(lst)

def stddev(lst, mean=None):
    if not mean:
        mean = sum(lst) / len(lst)
    return math.sqrt(sum((x - mean) ** 2 for x in lst) / len(lst))

def quartiles(lst):
    return percentile(lst, (25, 50, 75))

