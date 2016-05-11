VERSION = 0.1.1111

OUTDIR = Udapi-$(VERSION)/

all: clone doc

clone:
	mkdir -p $(OUTDIR)
	git clone https://github.com/martinpopel/newtreex $(OUTDIR)
	rm -rf $(OUTDIR)/cpp_raw
	rm -rf $(OUTDIR)/release
	rm -rf $(OUTDIR)/Makefile

doc:
	mkdir -p $(OUTDIR)/doc/python
	export PYTHONPATH=../python/:$PYTHONPATH && pydoc -w udapi.core.node.Node
	mv udapi.core.node.Node.html $(OUTDIR)/doc/python

clean:
	rm -rf $(OUTDIR)
