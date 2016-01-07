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


