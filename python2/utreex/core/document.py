#!/usr/bin/env python

import codecs
import re

from node import Node
from bundle import Bundle

class Document(object):

    attrnames = ["ord", "form", "lemma", "upostag", "xpostag", "feats", "head", "deprel", "deps"]  # TODO: pridat misc a poresit tolerovani jeho absence

    def __init__(self):
        self.bundles = []

    def __iter__(self):
        return iter(self.bundles)

    def load(self,filename):

        fh = open(filename, 'r')
        fh = codecs.getreader('utf8')(fh)

        nodes = []
        comment = ''

        for line in fh:

            if re.search('^#',line):
                comment = comment + line

            elif line.strip():

                if not nodes:
                    bundle = Bundle()
                    self.bundles.append(bundle)
                    root = Node()
                    root._aux['comment'] = comment # TODO: ulozit nekam poradne
                    nodes = [root]
                    bundle.trees.append(root)

                columns = line.strip().split('\t')
#                attrnames = ["ord", "form", "lemma", "upostag", "xpostag", "feats", "head", "deprel", "deps", "misc"]
                node = Node()
                nodes.append(node)

                for index in xrange(0,len(columns)-1):
                    setattr( node, Document.attrnames[index], columns[index] )
                
            else: # an empty line is guaranteed even after the last sentence in a conll-u file

                nodes[0]._aux['descendants'] = nodes[1:]
   
                for node in nodes[1:]:
                    node._parent
                
                nodes = []
                comment = ''


    def store(self,filename):

#        fh = open(filename, 'r')
#        fh = codecs.getreader('utf8')(fh)

        fh = codecs.open(filename,"w","utf-8")


        for bundle in self:
            for root in bundle:
                fh.write(root._aux['comment'])

                for node in root.descendants():
                    fh.write('\t'.join( [ getattr(node,attrname) for attrname in Document.attrnames ] ) )
                    fh.write('\n')

                fh.write("\n")

        fh.close()
