#!/usr/bin/env python

from operator import attrgetter

# ----- nasledujici jen kvuli tomu, abych mohl poustet benchmark (pri prevesovani nastavaji cykly a ocekava se RuntimeException) ---

class TreexException(Exception):
    "Common ancestor for Treex exception"
    def __init__(self, message):
        self.message = message

    def __str__(self):
        return 'TREEX-FATAL: ' + self.__class__.__name__ + ': ' + self.message

class RuntimeException(TreexException):
    "Block runtime exception"

    def __init__(self, text):
        TreexException.__init__(self, text)

# ---------------------------------------------------------------------------------------------




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

    def set_parent( self, new_parent ):

        if self.parent == new_parent:
            return

        elif self == new_parent:
            raise RuntimeException('setting the parent would lead to a loop: '+str(self))

        if self._parent:
            old_parent = self.parent

            climbing_node = new_parent

            while climbing_node:
                if climbing_node == self:
                    raise RuntimeException('setting the parent would lead to a loop: '+str(self))
                climbing_node = climbing_node.parent

            old_parent._children = [node for node in old_parent._children if node != self ]

        self._parent =new_parent
        new_parent._children = sorted( new_parent._children + [self], key=attrgetter('ord') )



    def descendants(self):
        if self.is_root():
            return self._aux['descendants']
        else:
            return sorted( self._unordered_descendants_using_children() )

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

    def shift_subtree_after(self, reference_node):
        nodes_to_move = [self] + self.descendants()

        for node_to_move in nodes_to_move:
            node_to_move.ord = reference_node.ord + 0.5 + (node_to_move.ord-self.ord)/10000
        self._update_ordering

    def shift_after(self, reference_node):  # TODO, silly, unify with the one above
        nodes_to_move = [self]

        for node_to_move in nodes_to_move:
            node_to_move.ord = reference_node.ord + 0.5 + (node_to_move.ord-self.ord)/10000
            self._update_ordering

    def prev_node(self):
        new_ord = self.ord - 1
        if new_ord < 0:
            return None
        if new_ord == 0:
            return self.root()
        return self.root()._aux['descendants'][self.ord - 1]

    def next_node(self):
        # Note that all_nodes[n].ord == n+1
        try:
            return self.root()._aux['descendants'][self.ord]
        except IndexError:
            return None
