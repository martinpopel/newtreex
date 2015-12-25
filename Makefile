SHELL=bash

help:
	# See README.md (https://github.com/martinpopel/newtreex)

data:
	wget -O ud1.2.tgz 'https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1548/ud-treebanks-v1.2.tgz?sequence=1&isAllowed=y'
	tar -xzf ud1.2.tgz
	mv universal-dependencies-1.2 data

.perl-install:
	cpanm Text::Table && touch $@

python-activate:
	export PYTHONPATH=`pwd`/python/pytreex/
	source python/venv/bin/activate

.python-install:
	virtualenv --version || sudo pip install virtualenv
	export PYTHONPATH=`pwd`/python/pytreex/
	cd python
	virtualenv venv
	source venv/bin/activate
	pip install unidecode pyyaml
	git clone git@github.com:ufal/pytreex.git
	cd pytreex && git checkout ud
	touch $@

.cpp_raw-compile:
	make -C cpp_raw

.java-build:
	gradle -b java/build.gradle wrapper && java/gradlew -b java/build.gradle build

#.old-treex-install:
#	cpanm Treex::Core

benchmark: data .perl-install .cpp_raw-compile
	./benchmark.pl data/UD_Romanian/ro-ud-train.conllu | tee results.txt
