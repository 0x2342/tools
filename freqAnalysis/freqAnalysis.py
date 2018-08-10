#!/usr/bin/env python
#
# Frequency analysis of a text files
# ETAOIN SHRDLU
# Started: 2017-11-08

import sys
from operator import itemgetter
from collections import OrderedDict

f = open(sys.argv[1], 'r');                                                 # Pass input file as parameter
s = str(f.read());                                                          # Read input from file
s = s.replace (" ","")                                                      # Strip whitespaces

ETAOINSHRDLU = ["e","t","a","o","i","n","s","h","r","d","l","u"]            # Most common single letters in the english language in descending order
#bigrams = ["th"]
#trigrams = ["the"]
chars = {"A":0, "B":0, "C":0, "D":0, "E":0, "F":0, "G":0, "H":0, "I":0, "J":0, "K":0, "L":0, "M":0, "N":0, "O":0, "P":0, "Q":0, "R":0, "S":0, "T":0, "U":0, "V":0, "W":0, "X":0, "Y":0, "Z":0}

def simpleFA( data ):
    for c in data:
        if c in chars:
            chars[c] += 1
    
    #res = dict()
    #for i in range(0,len(data)-1):
    #    c = data[i:i+1]
    #   if c in res:
    #        res[c] += 1
    #    else:
    #        res.update({c:1})

    orderedChars=OrderedDict(sorted(chars.items(), key=lambda x:-x[1]))
    return orderedChars

def bigrams( data ):
    res = dict()
    for i in range(0,len(data)-2):
        bigr = data[i:i+2]
        if bigr in res:
            res[bigr] +=1
        else:
            res.update({bigr:1})

    res=OrderedDict(sorted(res.items(), key=lambda x:-x[1]))
    return res

def trigrams( data ):
    res = dict()
    for i in range(0,len(data)-3):
        trigr = data[i:i+3]
        if trigr in res:
            res[trigr] += 1
        else:
            res.update({trigr:1})

    res=OrderedDict(sorted(res.items(), key=lambda x:-x[1]))
    return res

def substHeu( data ):
    single = simpleFA(data)
    bi = bigrams(data)
    tri = trigrams(data)
    print "Most common trigrams: " + tri.keys()[0] + "," + tri.keys()[1] + "," + tri.keys()[2]
    print "Most common digrams: " + bi.keys()[0] + "," + bi.keys()[1] + "," + bi.keys()[2]
    print "Most common characters: " + single.keys()[0] + "," + single.keys()[1] + "," + single.keys()[2]

    match = ( str(tri.keys()[0][0]) + str(tri.keys()[0][1]))            # Match most common bigram against first two letters of most common trigram
    d = dict()                                                          # Dictionary to hold assumed character mappings. Every key and every value should be unique :-)
    if match == str(bi.keys()[0]):
        d.update({tri.keys()[0]:'the'})
        d.update({tri.keys()[0][0]:'t'})
        d.update({tri.keys()[0][1]:'h'})
        d.update({tri.keys()[0][2]:'e'})
        d.update({bi.keys()[0]:'th'})
        d.update({bi.keys()[1]:'he'})
        # Now compare against ETAOINSHRDLU
        # Check whether we already have a mapping for elements from ETAOINSHRDLU and remove them
        for k,v in d.items():
            if v in ETAOINSHRDLU:
                ETAOINSHRDLU.remove(v)
                del single[k]
        #Now map remnants of ETAOINSHRDLU to single most characters in single[] dict
        for i in range(0,len(ETAOINSHRDLU)):
            d.update({single.keys()[i]:ETAOINSHRDLU[i]})
            #print "Mapping: " + single.keys()[i] + "-> " + ETAOINSHRDLU[i]

        #At this point I'd like to have d ordered by the length of key
        d=OrderedDict(sorted(d.items(), key=lambda x: -len(x[0])))
        print d

        for k,v in d.items():
            print "Replacing " + k + " with " + v
            data = data.replace(k,v)

    print data

substHeu(s)
f.close()
