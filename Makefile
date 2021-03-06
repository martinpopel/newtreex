SHELL=bash
DATA=data/UD_Romanian/ro-ud-train.conllu
DATASHORT=$(notdir $(DATA))
EXPS=pytreex udapi perl java cpp_raw
REPEATS=10
N=1

help:
	# See README.md (https://github.com/martinpopel/newtreex)
	# Usage:
	# make install
	# make benchmark EXPS='old_Treex pytreex udapi perl java cpp_raw' DATA=data/UD_Czech/cs-ud-train-l.conllu REPEATS=5

data:
	wget -O ud1.2.tgz 'https://lindat.mff.cuni.cz/repository/xmlui/bitstream/handle/11234/1-1548/ud-treebanks-v1.2.tgz?sequence=1&isAllowed=y'
	tar -xzf ud1.2.tgz
	mv universal-dependencies-1.2 data

.perl-install:
	cpanm MooX::Options MooX::TypeTiny Class::XSAccessor::Array Data::Printer Text::Table && touch $@

.python-install:
	virtualenv --version || sudo pip install virtualenv
	export PYTHONPATH=`pwd`/python/pytreex/ &&\
	cd python &&\
	virtualenv venv &&\
	source venv/bin/activate &&\
	pip install unidecode pyyaml &&\
	git clone git@github.com:ufal/pytreex.git
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

install:  data .perl-install .python-install .cpp_raw-compile

benchmark:
	export PYTHONPATH=`pwd`/python/pytreex/ &&\
	source python/venv/bin/activate &&\
	./benchmark.pl --input=$(DATA) --repeats=$(REPEATS) -n $(N) $(EXPS) | (trap "" SIGINT SIGQUIT; tee -a results_$(DATASHORT).txt)

bu: # a quick test of udapi benchmarked
	./benchmark.pl --input=$(DATA) --repeats=1 udapi | tee results_$(DATASHORT).txt
