#!/usr/bin/env python
#
# Takes a file encrypted under a Vigenere cipher and attempts to recover the key
#
# Started: 2017-11-09

import sys
from collections import OrderedDict

#TODO: Read lines from file instead of a single string
#with open(sys.argv[1], 'r') as f:
#    s = f.readlines()
#s = [x.replace(" ","") for x in s]

f = open(sys.argv[1], 'r')
s = str(f.read())
s = s.replace(" ","")

keylength = 6

def findall(p, s):
    i = s.find(p)
    while i != -1:
        yield i
        i = s.find(p,i+1)

def kasiski( data ):
    # Find n-grams
    # compute distance
    res = dict()
    for i in range(0,len(data)-3):
        trigr = data[i:i+3]
        if trigr in res:
            res[trigr] += 1
        else:
            res.update({trigr:1})
    res = OrderedDict(sorted(res.items(), key=lambda x:-x[1]))
    i = [ data.find(res.keys()[0]) ]
    while i != -1:
        print data.find(res.keys()[0], i+1)

    return 0

def friedman( data ):
    return 0

#Return a string containing every n-th character of the input
def getSubString( s, start, offset ):
    res = ""
    pos = start
    while pos < len(s)+1:
        res += s[pos-1]
        pos += offset

    return res

#Return set of keys with maximal value, expects OrderedDict as input
def getMaxKeys( data ):
    maxKeys = dict()
    maxKeys.update({data.keys()[0]:data.values()[0]})
    for i in range(1, len(data)):
        if data.values()[i] == maxKeys.values()[0]:
            maxKeys.update({data.keys()[i]:data.values()[i]})
    
    return maxKeys

#Perform frequency analysis of columns based on keylength
def analyse( data ):
    dicts = dict()                  # dict of dicts :-)
    for i in range(1,keylength+1):  # e.g. d1,...,dn
        dicts[i] = dict()
    
    # Fill dictionaries
    for i in range(1,keylength+1):
        s = getSubString(data,i,6)
        for c in s:
            if c in dicts[i]:
                dicts[i][c] += 1
            else:
                dicts[i].update({c:1})
        dicts[i]=OrderedDict(sorted(dicts[i].items(), key=lambda x:-x[1]))
    
    for i in range(1, keylength+1):
        maxKeys = getMaxKeys(dicts[i])
        print "Most frequent char in column " + str(i) +": " + str(maxKeys)

    print dicts
    return 0

#res = analyse(s)
res = kasiski(s)
