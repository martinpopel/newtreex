#!/usr/bin/env python
#
# benchmark
# run with "python -u" to disable buffering
#

__author__ = "Martin Popel, Zdenek Zabokrtsky"
__date__ = "2016"

import sys
import random # bude nahrazeno pseudonahodnosti
import os

sys.path.append( os.path.dirname(os.path.abspath(__file__)) + '/utreex/')
from utreex.core.document import Document
from utreex.core.node import RuntimeException


print("init")


doc = Document()
doc.load({'filename':sys.argv[1]})

print("load")

doc.store({'filename':sys.argv[2]})

print("save")

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
            rand_index = random.randint(0,len(nodes)-1)
            try:
                node.set_parent(nodes[rand_index])
            except RuntimeException:
                pass

print("rehang")

for bundle in doc:
    for root in bundle:
        for node in root.descendants():
            if random.random() < 0.1:
                node.remove()

print("remove")

#for bundle in doc.bundles:
#    for zone in bundle.get_all_zones():
#        for node in zone.atree.get_descendants(ordered=1):
#            if random.random() < 0.1:
#                node.create_child(data={'form': 'x', 'lemma': 'x'}).shift_after_subtree(node)

print("add")

#for bundle in doc.bundles:
#    for zone in bundle.get_all_zones():
#        nodes = zone.atree.get_descendants(ordered=1)
#        for node in nodes:
#            rand_index = random.randint(0,len(nodes)-1)
#            if random.random() < 0.1:
#                # Catch an exception if nodes[rand_index] is a descendant of $node
#                node.shift_after_node(nodes[rand_index])
#            elif random.random() < 0.1:
#                node.shift_before_subtree(nodes[rand_index], without_children=1)

print("reorder")
