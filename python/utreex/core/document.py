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

    def load(self,args):
        
        fh = None

        try:
            fh = args['filehandle']
        except:
            filename = args['filename']
            fh = open(filename, 'r')

        fh = codecs.getreader('utf8')(fh)

        nodes = []
        comment = ''

        for line in fh:

            if re.search('^#',line):
                comment = comment + line

            elif re.search('^\d+\-',line):  # HACK: multiword tokens temporarily avoided
                pass

            elif line.strip():

                if not nodes:
                    bundle = Bundle()
                    self.bundles.append(bundle)
                    root = Node()
                    root.ord = 0
                    root._aux['comment'] = comment # TODO: ulozit nekam poradne
                    nodes = [root]
                    bundle.trees.append(root)

                columns = line.strip().split('\t')

                node = Node()
                nodes.append(node)

                for index in xrange(0,len(Document.attrnames)):
                    setattr( node, Document.attrnames[index], columns[index] )

                try:  # TODO: kde se v tomhle sloupecku berou podtrzitka
                    node.head = int(node.head)
                except ValueError:
                    node.head = 0

                try:   # TODO: poresit multitokeny
                    node.ord = int(node.ord)
                except ValueError:
                    node.ord = 0


            else: # an empty line is guaranteed even after the last sentence in a conll-u file

                nodes[0]._aux['descendants'] = nodes[1:]
   
                for node in nodes[1:]:

                    node.set_parent( nodes[node.head] )
                
                nodes = []
                comment = ''


    def store(self,args):

        try:
            fh = args['filehandle']
        except:
            filename = args['filename']
            fh = codecs.open(filename,'w','utf-8')

        for bundle in self:
            for root in bundle:
                fh.write(root._aux['comment'])

                for node in root.descendants():

                    values = [ getattr(node,attrname) for attrname in Document.attrnames ]
                    values[0] = str(values[0]) # ord

                    try:
                        values[6] = str(node.parent.ord)
                    except:
                        values[6] = '0'

                    fh.write('\t'.join(values) )
                    fh.write('\n')

                fh.write("\n")

        fh.close()
