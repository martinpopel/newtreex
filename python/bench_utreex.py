#!/usr/bin/env python
#
# benchmark
# run with "python -u" to disable buffering
#

__author__ = "Martin Popel, Zdenek Zabokrtsky"
__date__ = "2016"

import sys
import os
import gc

sys.path.append( os.path.dirname(os.path.abspath(__file__)) + '/utreex/')
from utreex.core.document import Document, Node
from utreex.core.node import RuntimeException

seed = 42;
maxseed = 2**32;
def myrand(modulo):
    global seed
    seed = (1103515245 * seed + 12345) % maxseed;
    return seed % modulo;

print("init")


doc = Document()
doc.load({'filename':sys.argv[1]})

print("load")


for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            pass

print("iter")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            pass

print("iterF")

for bundle in doc:
    for root in bundle:
        for child in root.children:
            for node in child.descendants():
                pass

print("iterS")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            form_lemma = node.form + node.lemma

print("read")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            node.deprel = 'dep'

print("write")

for bundle in doc:
    for root in bundle:
        nodes = root.descendants()
        for node in nodes:
            rand_index = myrand(len(nodes))
            try:
                node.set_parent(nodes[rand_index])
            except RuntimeException:
                pass

print("rehang")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            if myrand(10) == 0:
                node.remove()

print("remove")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            pass
            if myrand(10) == 0:
                child = Node()
                child.ord = 100000 # TODO: silly
                child.set_parent(node)
                child.shift_after(node)
                child.lemma="x"
                child.form="x"

print("add")

for bundle in doc:
    for root in bundle:
        nodes = root.descendants()
        for node in nodes:
            rand_index = myrand(len(nodes))
            if myrand(10) == 0:
                # Catch an exception if nodes[rand_index] is a descendant of $node
                node.shift_subtree_after(nodes[rand_index])
            elif myrand(10) == 0:
                node.shift_after(nodes[rand_index])  # TODO: dodelat, tady se chce neco trochu jineho

print("reorder")


doc.store({'filename':sys.argv[2]})
print("save")

#del doc
#gc.collect()
#print("free")

print("end")
