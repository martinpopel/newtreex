# New Treex
Experiments with efficient API for processing dependency trees (new version of [Treex](https://github.com/ufal/treex)).

## Benchmark
First, run `make data` to download [UD 1.2](http://hdl.handle.net/11234/1-1548) and store in `data` directory.
See definition of the [CoNLL-U](https://universaldependencies.github.io/docs/format.html) data format.
Add your implementation of the New Treex API (TODO: add a link to the specification) in a directory named by the programming language of your choice (python, perl, java, c,...).
Add possible compilation into the [Makefile](Makefile).
Edit `@experiments` in [benchmark.pl](benchmark.pl) so it calls a command which runs the benchmark on selected treebanks.
For correct memory consumption statistics the command should not contain shell metacharacters and it should not execute any child process.
The command may contain options to run different version of your implementation (e.g. prioritizing speed over memory).
Finally, run `make benchmark`.

The benchmark command should do several tasks and after finishing each task print the task name on STDOUT.
Nothing else should be printed on STDOUT. The tasks are:

1. **init** intialize whatever is needed
2. **load** load the CoNLL-U file (specified as parameter) to memory
3. **save** save the in-memory document to an output CoNLL-U file (specified as parameter), it should have exactly the same content as the input file (`diff` check will be added later)

TODO: more tasks will be added here in future (rehanging random nodes, adding&deleting nodes, changing word order of nodes, accessing attributes, adding&deleting sentences...).

### Current results
MAXMEM is maximum (virtual) memory (`ps -ovsz`) in MiB.
Other columns are time in seconds. Run on x86_64.
For start, I've selected Romanian dev set (on of the smallest files in UD 1.2), later we'll add experiments on bigger files (Czech is the biggest).

| experiment       | init | load | save | TOTAL | MAXMEM |
|------------------|-----:|-----:|-----:|------:|-------:|
| old_treex-ro_dev |    2 |    8 |    1 |    11 |    195 |

