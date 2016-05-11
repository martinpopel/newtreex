#!/usr/bin/bash

export PATH=../python/bin:$PATH
export PYTHONPATH=../python/lib:$PYTHONPATH

udapi.py read.Conllu filename=sample.conllu Dummy write.Conllu > transformed.conllu
