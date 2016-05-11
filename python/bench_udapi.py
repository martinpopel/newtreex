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

sys.path.append( os.path.dirname(os.path.abspath(__file__)) + '/src/udapi/')
from udapi.core.document import Document, Node
from udapi.core.node import RuntimeException

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
if debug: doc.store({'filename':'udapi-load.conllu'})

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
if debug: doc.store({'filename':'udapi-write.conllu'})

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
if debug: doc.store({'filename':'udapi-rehang.conllu'})

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            if myrand(10) == 0:
                node.remove()

print("remove")
if debug: doc.store({'filename':'udapi-remove.conllu'})

for bundle in doc:
    for root in bundle:
        for parent in root.descendants():
            if myrand(10) == 0:
                child = parent.create_child()
                child.lemma="x"
                child.form="x"
                child.shift(parent,1,0,1)

print("add")


if debug: doc.store({'filename':'udapi-add.conllu'})

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
if debug: doc.store({'filename':'udapi-reorder.conllu'})

doc.store({'filename':out_conllu})
print("save")

#del doc
#gc.collect()
#print("free")

print("end")
