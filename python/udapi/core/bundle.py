#!/usr/bin/env python

import codecs
import re

from node import Node

class Bundle(object):

    __slots__ = [ "trees", "_aux" ]

    def __init__(self):
        self.trees = []

    def __iter__(self):
        return iter(self.trees)

    def tree_by_zone(self,zone):
        trees = [tree for tree in self.trees if tree.zone == zone]
        if len(trees) == 1:
            return trees[0]
        elif len(trees) == 0:
            raise Exception( "No tree with zone="+zone+" in the bundle")
        else:
            raise Exception("More than one tree with zone="+zone+" in the bundle")
        



