#!/usr/bin/env python

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
                  "_auxattr"     # other attributes (other than misc)    

    ]
   

    def __init__(self, data={}):

        self._parent = None
        self._children = []
        self._wild = {}

        for name in data:
#            print "setting "+str(name)+" to "+str(data[name])
            setattr(self,name,data[name])

    @property
    def children(self):
        return self._children


    @property
    def parent(self):
        return self._parent


#    def __iter__(self):
#        yield self
#        for child in self.children:
#            for node in child:
#                yield nod
