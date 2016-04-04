#!/usr/bin/env python

#from node import Node
#from bundle import Bundle

from document import Document

class Run(object):

    def __init__(self, scenario_string):
        self.blocks = []



    def __parse_scenario_string(self):
        pass

    def __import_block_class(self,block_class_name):
        pass


    def run(self):                                                                              pass     
        

    def execute(self):

        block_names = []
        block_args = []

        # 1. parse scenario string

        # 2. import blocks (classes) and construct block instances

        blocks = []

        for block_name in block_names:
            sub_path, class_name = block_data["block"].rsplit('.', 1)
            module = "utreex." + path + "." + class_name.lower()
            exec "import module"
            blocks.append = eval "utreex"+sub_path+class_name+"()"

        # 4. initialize blocks (process_start)
        for block in blocks:
            block.process_start()

        # 5. apply blocks on the data
        finish = 0
        while not finish:
            document = Document
            for block in blocks:
                finish = finish or block.process_document(document)


        # 6. close blocks (process_end) 
        for block in blocks:
            block.process_end()
