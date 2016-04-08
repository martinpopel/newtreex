#!/usr/bin/env python

#from node import Node
#from bundle import Bundle

class Block(object):

#    def __init__(self):
#        self.bundles = []

    def process_start(self):
        pass

    def process_end(self):
        pass

    def process_node(self, node):
        raise Exception("No processing activity defined in block "+str(self))

    def process_tree(self,tree):
        for node in tree.descendants():
            self.process_node(node)

    def process_bundle(self,bundle):
        for tree in bundle:
            self.process_tree(tree)

    def process_document(self,document):
        print "Document "+str(document)
        print str(document.bundles)
        for bundle in document.bundles:
            self.process_bundle(bundle)

