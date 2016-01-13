#!/usr/bin/env python

from operator import attrgetter

class Node(object):

    __slots__ = [ 
                   # (A) features following the CoNLL-U documentation
                  "ord",      # Word index, integer starting at 1 for each new sentence; may be a range for tokens with multiple words.
                  "form",     # Word form or punctuation symbol.
                  "lemma",    # Lemma or stem of word form.
                  "upostag",  # Universal part-of-speech tag drawn from our revised version of the Google universal POS tags.
                  "xpostag",  #  Language-specific part-of-speech tag; underscore if not available.
                  "feats",    # List of morphological features from the universal feature inventory or from a defined language-specific extension; underscore if not available.
                  "head",     # Head of the current token, which is either a value of ID or zero (0).
                  "deprel",   # Universal Stanford dependency relation to the HEAD (root iff HEAD = 0) or a defined language-specific subtype of one.
                  "deps",     # List of secondary dependencies (head-deprel pairs).
                  "misc",     # Any other annotation.

                   # (B) utreex-specific extra features                            

                  "_parent",  # parent node
                  "_children",# ord-ordered list of child nodes  
                  "_aux"     # other technical attributes

    ]
   

    def __init__(self, data={}):

        self._parent = None
        self._children = []
        self._aux = {}

        for name in data:
            setattr(self,name,data[name])

    @property
    def children(self):
        return self._children


    @property
    def parent(self):
        return self._parent

    def set_parent(self,parent):

        if self._parent:
            old_parent = self.parent

            climbing_node = old_parent
            while climbing_node:
                if climbing_node == self:
                    raise SystemExit('setting the parent would lead to a loop: '+self)
                climbing_node = climbing_node.parent

            old_parent._children = [node for node in old_parent._children if node != self ]

        self._parent = parent
        parent._children = sorted( parent._children + [self], key=attrgetter('ord') )

    def descendants(self):
        if self._aux['descendants']:
            return self._aux['descendants']
        else:
            return self._descendants_using_children()

    def _unordered_descendants_using_children(self):
        descendants = [self]
        for child in self.children:
            descendants.extend(child._unordered_descendants_using_children())
        return descendants
        
    def root(self):
        node = self
        while (node.parent):
            node = node.parent
        return node

    def is_root(self):
        return not self.parent

    def _update_ordering(self):
         """ update the ord attribute in all nodes and update the list or descendants stored in the tree root (after node removal or addition) """
         root = self.root()

         descendants = sorted( [node for node in root._unordered_descendants_using_children() if node != root] ,
                               key=attrgetter('ord') )

         root._aux['descendants'] = descendants

         for ord in range(0,len(root._aux['descendants'])):
             descendants[ord].ord = ord+1

            

    def remove(self):

        self.parent._children = [ child for child in self.parent._children if child != self ]
        self.parent._update_ordering()

    def reorder(self,new_ord):
        self.ord = new_ord
        
