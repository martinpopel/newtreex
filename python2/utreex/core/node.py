#!/usr/bin/env python

class Node(object):

    def __init__(self, data={}):
        self.bundles = []
        self.parent = None
        for name in data:
#            print "setting "+str(name)+" to "+str(data[name])
            setattr(self,name,data[name])


    def __iter__(self):
        yield self
        for child in self.children:
            for node in child:
                yield nod
