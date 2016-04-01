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

debug = False
if sys.argv[1] == "-d":
    debug = True
    sys.argv.pop(1)
in_conllu = sys.argv[1]
out_conllu = sys.argv[2]

print("init")

doc = Document()
doc.load({'filename':in_conllu})

print("load")
if debug: doc.store({'filename':'utreex-load.conllu'})

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
        node = root
        while node:
            node = node.next_node();

print("iterN")

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
if debug: doc.store({'filename':'utreex-write.conllu'})

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
if debug: doc.store({'filename':'utreex-rehang.conllu'})

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            if myrand(10) == 0:
                node.remove()

print("remove")
if debug: doc.store({'filename':'utreex-remove.conllu'})

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            if myrand(10) == 0:
                child = Node()
                child.ord = 100000 # TODO: silly
                child.set_parent(node)
                child.shift_after(node)
                child.lemma="x"
                child.form="x"

print("add")
if debug: doc.store({'filename':'utreex-add.conllu'})

for bundle in doc:
    for root in bundle:
        nodes = root.descendants()
        for node in nodes:
            rand_index = myrand(len(nodes))
            if myrand(10) == 0: 
                if not nodes[rand_index].is_descendant_of(node):
                    node.shift(nodes[rand_index], after=1, move_subtree=1, reference_subtree=0)
            elif myrand(10) == 0:
                node.shift(nodes[rand_index], after=0, move_subtree=0, reference_subtree=1)

print("reorder")
if debug: doc.store({'filename':'utreex-reorder.conllu'})

doc.store({'filename':out_conllu})
print("save")

#del doc
#gc.collect()
#print("free")

print("end")
