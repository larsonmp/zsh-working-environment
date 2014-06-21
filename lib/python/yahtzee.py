#!/usr/bin/env python

from optparse import OptionParser
import random

def roll(n, d):
    return [random.randint(1, d) for value in range(n)]

def get_mode(array):
    dict = {}
    for item in array:
        dict[item] = dict.get(item, 0) + 1
    if dict.values():
        value = max(dict.values())
        for key in dict.keys():
            if dict[key] == value:
                return (key, value) #(mode, occurances of mode)
    return (None, None)

def keep(previousRollsMode, currentRollNewMode, currentRollOldMode):
    if not previousRollsMode:
        return currentRollNewMode
    if previousRollsMode[0] == currentRollNewMode[0]:
        return previousRollsMode + currentRollNewMode
    if len(currentRollNewMode) < len(previousRollsMode) + len(currentRollOldMode):
        return previousRollsMode + currentRollOldMode
    if len(previousRollsMode) < len(currentRollNewMode):
        return currentRollNewMode
    else:
        return previousRollsMode

def determine_yahtzee_probability(n, d, r, t):
    yahtzees = 0
    for trial in range(t):
        if try_for_a_yahtzee(n, d, r):
            yahtzees += 1
    return float(yahtzees) / float(t)

def try_for_a_yahtzee(n, d, r):
    currentHand = []
    for attempt in range(r):
        rollResults = roll(n - len(currentHand), d)
        (newMode, occurancesOfNewMode) = get_mode(rollResults)
        currentRollNewMode = [newMode] * occurancesOfNewMode
        if currentHand and 0 < rollResults.count(currentHand[0]):
            currentRollOldMode = [currentHand[0]] * rollResults.count(currentHand[0])
        else:
            currentRollOldMode = []
        currentHand = keep(currentHand, currentRollNewMode, currentRollOldMode)
        #check for a yahtzee after each round, stop if we got one
        if len(currentHand) == n:
           return True
    return False

def main():
    #TODO: use argparse when python 2.7 becomes available
    parser = OptionParser()
    parser.add_option('-d', '--dice',   dest='n',                type='int', help='The number of dice to roll',   metavar='N')
    parser.add_option('-r', '--rolls',  dest='r',                type='int', help='The number of rolls allowed',  metavar='N')
    parser.add_option('-s', '--sides',  dest='d', default=6,     type='int', help='The number of sides on a die', metavar='N')
    parser.add_option('-t', '--trials', dest='t', default=2**20, type='int', help='The number of attempts/turns', metavar='N')
    
    (options, args) = parser.parse_args()
    
    #normal yahtzee: n = 5, r = n - 2 = 3, d = 6
    sidesOnADie = options.d
    numTrials = options.t
    if options.n:
        setsOfDice = [ options.n ]
    else:
        setsOfDice = range(3, 20) + range(20, 51, 5)
    
    for numDice in setsOfDice:
        if options.r:
            numRolls = options.r
        else:
            numRolls = numDice - 2
        probability = determine_yahtzee_probability(numDice, sidesOnADie, numRolls, numTrials)
        print '%2dd%d, %d rolls: %0.4f%% chance of a yahtzee' % (numDice, sidesOnADie, numRolls, 100.0 * probability)
    
if __name__ == '__main__':
    main()

