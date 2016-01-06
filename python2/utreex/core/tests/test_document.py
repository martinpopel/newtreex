#!/usr/bin/env python

import unittest

from utreex.core.document import Document

class TestDocument(unittest.TestCase):

    def test_init(self):
        doc = Document()

    def test_iterator(self):
        doc = Document()
        doc.bundles = ['a','b','c']
        for bundle in doc:
            print bundle

    def test_load(self):
        doc = Document()
        doc.load("in.conll")



if __name__ == "__main__":
    unittest.main() 
