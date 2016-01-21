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
from pytreex.core.document import Document
from pytreex.core.exception import RuntimeException
from pytreex.block.read.conllu import ReadCoNLLU
from pytreex.block.write.conllu import WriteCoNLLU


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

conllu_reader = ReadCoNLLU(None, dict())
conllu_writer = WriteCoNLLU(None, {'to':out_conllu, 'language':'unk'})
print("init")

doc = conllu_reader.process_document(in_conllu)
print("load")
if debug: WriteCoNLLU(None, {'to':'pytreex-load.conllu', 'language':'unk'}).process_document(doc)

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
if debug: WriteCoNLLU(None, {'to':'pytreex-write.conllu', 'language':'unk'}).process_document(doc)

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        nodes = zone.atree.get_descendants(ordered=1)
        for node in nodes:
            rand_index = myrand(len(nodes))
            try:
                node.parent = nodes[rand_index]
            except RuntimeException:
                pass
print("rehang")
if debug: WriteCoNLLU(None, {'to':'pytreex-rehang.conllu', 'language':'unk'}).process_document(doc)

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            if myrand(10) == 0:
                try:
                    node.remove()
                # if the node was already deleted, Pytreex raises a bit unintuitive exception
                except KeyError:
                    pass
print("remove")
if debug: WriteCoNLLU(None, {'to':'pytreex-remove.conllu', 'language':'unk'}).process_document(doc)

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        for node in zone.atree.get_descendants(ordered=1):
            if myrand(10) == 0:
                node.create_child(data={'form': 'x', 'lemma': 'x'}).shift_after_subtree(node)
print("add")
if debug: WriteCoNLLU(None, {'to':'pytreex-add.conllu', 'language':'unk'}).process_document(doc)

for bundle in doc.bundles:
    for zone in bundle.get_all_zones():
        nodes = zone.atree.get_descendants(ordered=1)
        for node in nodes:
            rand_index = myrand(len(nodes))
            if myrand(10) == 0:
                try:
                    node.shift_after_node(nodes[rand_index])
                except RuntimeException: # nodes[rand_index] is descendant of node
                    pass
            elif myrand(10) == 0:
                node.shift_before_subtree(nodes[rand_index], without_children=True)
print("reorder")
if debug: WriteCoNLLU(None, {'to':'pytreex-reorder.conllu', 'language':'unk'}).process_document(doc)

conllu_writer.process_document(doc)
print("save")
