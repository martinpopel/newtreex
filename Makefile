SHELL=bash

help:
	# See README.md (https://github.com/martinpopel/newtreex)

data:
	wget -O ud1.2.tgz 'https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1548/ud-treebanks-v1.2.tgz?sequence=1&isAllowed=y'
	tar -xzf ud1.2.tgz
	mv universal-dependencies-1.2 data

.perl-install:
	cpanm Text::Table && touch $@

#.old-treex-install:
#	cpanm Treex::Core

benchmark: data .perl-install
	./benchmark.pl | tee results.txt
