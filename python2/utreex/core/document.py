#!/usr/bin/env python

import codecs
import re

from node import Node

class Document:

    def __init__(self):
        self.trees = []

    def __iter__(self):
        return iter(self.trees)

    def load(self,filename):

        fh = open(filename, 'r')
        fh = codecs.getreader('utf8')(fh)

        count = 0
        nodes = []

        for line in fh:

            if not line.strip():
                count += 1
#                bundle = Bundle()
                nodes = []

            else:
                columns = line.strip().split('\t')
                columns.append(0)
                ord,form,lemma,tag,parent = columns

                node = Node( { 'ord':ord,
                               'form':form,
                               'lemma':lemma,
                               'tag':tag } )
                nodes.append(node)
#                print form




        print "QQQQQQempty lines: "+str(count)
