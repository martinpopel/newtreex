#!/usr/bin/env python

import unittest

from utreex.core.node import Node

class TestDocument(unittest.TestCase):

    def test_init(self):
        node = Node()

    def test_parent(self):
        p = Node()
        c = Node({"parent":p,"lemma":"prasopes"})
    

#    def test_iterator(self):
#        doc = Document();
#        doc.bundles = ['a','b','c']
#        for bundle in doc:
##            print bundle



if __name__ == "__main__":
    unittest.main() 
