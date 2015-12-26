SHELL=bash
DATA=data/UD_Romanian/ro-ud-train.conllu
DATASHORT=$(notdir $(DATA))
EXPS=old_Treex pytreex perl_plain java cpp_raw

help:
	# See README.md (https://github.com/martinpopel/newtreex)
	# Usage:
	# make benchmark EXPS='old_Treex pytreex perl_plain java cpp_raw' DATA=data/UD_Romanian/ro-ud-train.conllu

data:
	wget -O ud1.2.tgz 'https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1548/ud-treebanks-v1.2.tgz?sequence=1&isAllowed=y'
	tar -xzf ud1.2.tgz
	mv universal-dependencies-1.2 data

.perl-install:
	cpanm Text::Table && touch $@

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
	# First install gradle, but the 1.4 version in Ubuntu 14.04 repos is too old,
	# so either wget https://services.gradle.org/distributions/gradle-2.10-bin.zip
	# or
	# sudo add-apt-repository ppa:cwchien/gradle
	# sudo apt-get update
	# sudo apt-get install gradle
	gradle -b java/build.gradle wrapper && java/gradlew -b java/build.gradle build

#.old-treex-install:
#	cpanm Treex::Core

benchmark: data .perl-install .cpp_raw-compile
	export PYTHONPATH=`pwd`/python/pytreex/ &&\
	source python/venv/bin/activate &&\
	./benchmark.pl $(DATA) $(EXPS) | tee results_$(DATASHORT).txt
