#!/usr/bin/env python3
#
# benchmark
# run with "python3 -u" to disable buffering
#

__author__ = "Martin Popel, Zdenek Zabokrtsky"
__date__ = "2016"

import sys
import os
import gc

import udapi

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

doc = udapi.Document(in_conllu)

print("load")
if debug: doc.store_conllu('udapi-load.conllu')

for bundle in doc:
    for root in bundle:
        for node in root.descendants:
            pass

print("iter")

for node in doc.nodes:
    pass

print("iterF")

for bundle in doc:
    for root in bundle:
        for child in root.children:
            for node in child.descendants:
                pass

print("iterS")

for bundle in doc:
    for root in bundle:
        node = root
        while node:
            node = node.next_node;

print("iterN")

for bundle in doc:
    for root in bundle:
        for node in root.descendants:
            form_lemma = node.form + node.lemma

print("read")

for bundle in doc:
    for root in bundle:
        for node in root.descendants:
            node.deprel = 'dep'

print("write")
if debug: doc.store_conllu('udapi-write.conllu')

for bundle in doc:
    for root in bundle:
        nodes = root.descendants
        for node in nodes:
            rand_index = myrand(len(nodes))
            try:
                node.parent = nodes[rand_index]
            except ValueError:
                pass

print("rehang")
if debug: doc.store_conllu('udapi-rehang.conllu')

for bundle in doc:
    for root in bundle:
        for node in root.descendants:
            if myrand(10) == 0:
                node.remove()

print("remove")
if debug: doc.store_conllu('udapi-remove.conllu')

for bundle in doc:
    for root in bundle:
        for parent in root.descendants:
            if myrand(10) == 0:
                child = parent.create_child(form="x", lemma="x")
                child.shift_after_subtree(parent)

print("add")

if debug: doc.store_conllu('udapi-add.conllu')

for bundle in doc:
    for root in bundle:
        nodes = root.descendants
        for node in nodes:
            rand_index = myrand(len(nodes))
            if myrand(10) == 0: 
                #if not nodes[rand_index].is_descendant_of(node):
                node.shift_after_node(nodes[rand_index], skip_if_descendant=True)
            elif myrand(10) == 0:
                node.shift_before_subtree(nodes[rand_index], without_children=True)

print("reorder")
if debug: doc.store_conllu('udapi-reorder.conllu')

doc.store_conllu(out_conllu)
print("save")

#del doc
#gc.collect()
#print("free")

print("end")
