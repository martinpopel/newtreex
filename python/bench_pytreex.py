#!/usr/bin/env python
# coding=utf-8
#
# benchmark
# run with "python -u" to disable buffering
#
from __future__ import unicode_literals

__author__ = "Martin Popel"
__date__ = "2015"



import sys
import random
from pytreex.core.document import Document
from pytreex.core.exception import RuntimeException
from pytreex.block.read.conllu import ReadCoNLLU
from pytreex.block.write.conllu import WriteCoNLLU
conllu_reader = ReadCoNLLU(None, dict())
conllu_writer = WriteCoNLLU(None, {'to':sys.argv[2], 'language':'unk'})
print("init")

doc = conllu_reader.process_document(sys.argv[1])
print("load")

conllu_writer.process_document(doc)
print("save")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            pass
print("iter")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants():
            pass
print("iterF")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            form_lemma = node.form + node.lemma
print("read")
        
for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            node.deprel = 'dep'
print("write")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        nodes = zone.atree.get_descendants(ordered=1)
        for node in nodes:
            rand_index = random.randint(0,len(nodes)-1)
            try:
                node.parent = nodes[rand_index]
            except RuntimeException:
                pass
print("rehang")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            if random.random() < 0.1:
                try:
                    node.remove()
                # if the node was already deleted, Pytreex raises a bit unintuitive exception
                except KeyError:
                    pass
print("remove")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            if random.random() < 0.1:
                node.create_child(data={'form': 'x', 'lemma': 'x'}).shift_after_subtree(node)
print("add")

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        nodes = zone.atree.get_descendants(ordered=1)
        for node in nodes:
            rand_index = random.randint(0,len(nodes)-1)
            if random.random() < 0.1:
                # Catch an exception if nodes[rand_index] is a descendant of $node
                node.shift_after_node(nodes[rand_index])
            elif random.random() < 0.1:
                node.shift_before_subtree(nodes[rand_index], without_children=1)
print("reorder")
