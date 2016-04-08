#!/usr/bin/env python

#from node import Node
#from bundle import Bundle


from document import Document
from basereader import BaseReader
import re
import sys
import os

sys.path.append( os.path.dirname(os.path.abspath(__file__)) + '/../../')

class Run(object):

    def __init__(self, scenario_string="", command_line_argv=[]):
        self.scenario_string = scenario_string
        self.command_line_argv = command_line_argv


    def run(self):
        pass     
        

    def execute(self):

        block_names = []
        block_args = []

        # 1. parse scenario string
        

        number_of_blocks = 0

        for arg in self.command_line_argv[1:]:
            print "token "+arg
            if not '=' in arg:
                print "Rozpoznan nazev bloku"
                block_names.append(arg)
                block_args.append({})
                number_of_blocks += 1
            else:
                print "rozpoznan argument"
                attrname,attrvalue = arg.split('=',2)  # TODO: test for another '=' inside quotes 
                if (number_of_blocks == 0):
                    print "block attribute pair "+arg+" without a prior block name" # TODO, dodelat, asi nahodit vyjimku
                    raise
                block_args[number_of_blocks-1][attrname] = attrvalue


        # 2. import blocks (classes) and construct block instances

        blocks = []

        for block_number in range(0,number_of_blocks-1):
            sub_path, class_name = ("."+block_names[block_number]).rsplit('.', 1)
            module = "utreex.block" + sub_path + "." + class_name.lower()
            try:
                command = "from " + module + " import " + class_name + " as b" + str(block_number)
                print "Trying to run this: "+command
                exec(command)
            except:
                print "Error when trying import the block"
                raise
            
            command = "b"+str(block_number)+"(block_args[block_number])"
            print "Trying to evaluate this: "+command
            new_block_instance =  eval (command)
            blocks.append(new_block_instance)

        # 4. initialize blocks (process_start)
        for block in blocks:
            block.process_start()

        # 5. apply blocks on the data

        readers = [block for block in blocks if issubclass(block.__class__,BaseReader)]

        finished = False
        while not finished:
            document = Document
            print "    New round"
            for block in blocks:
                print "        Executing block: "+str(block.__class__)
                block.process_document(document)

            finished = True
            for reader in readers:
                finished = finished and reader.finished

        print "No more unfinished readers => all data is done"


        # 6. close blocks (process_end) 
        for block in blocks:
            block.process_end()

if __name__ == "__main__":
    print "Bezim"

    runner = Run(command_line_argv = sys.argv )
    runner.execute()
