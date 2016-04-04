from utreex.core.block import Block

class Dummy(Block):
    def process_tree(self):
        print "Ahoj"
