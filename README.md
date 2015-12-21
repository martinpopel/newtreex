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

1. **init** Intialize whatever is needed.
2. **load** Load the CoNLL-U file (specified as parameter) to memory.
3. **save** Save the in-memory document to an output CoNLL-U file (specified as parameter). It should have exactly the same content as the input file (TODO `diff` check can be added later).
4. **iter** Iterate over all nodes in all sentences by their word order.
5. **iterF** Iterate over all nodes (fast). Nodes within one sentence may be iterated in any order.
6. **read** Iterate over all nodes (by their word order, this holds for the rest of the tasks) and create a variable with concatenated *form* and *lemma*.
7. **write** Set `deprel` attribute of each node to the value `dep`.
8. **rehang** Rehang each node to a random parent in the same sentence. Method `set_parent` should raise an exception if this would lead to a cycle. Catch such exceptions and leave such nodes under their original parents.
9. **remove** Delete random 10% of nodes. That is `if (rand() < 0.1 ){ $node->remove()}`, so it does not need to be exactly 10%. Removing a node by default removes all its descendants. (Note that if you iterate over a list of original nodes, you may encounter already deleted nodes. You should check this case and don't try to delete already deleted nodes.)
10. **add** Select random 10% of nodes (as above) and add a child under them (*lemma*=x, *form*=x). It should be the last child according to word order (and last=rightmost descendant).
11. **reorder** Shift 10% of nodes (with their whole subtree) after random node (except when that random node is a descendant). From the rest of the nodes, shift 10% of nodes without their subtree before a random subtree. That is:
```
  if (rand() < 0.1 ){
    try{$node->shift_after_node($nodes[$rand_index]);}
    # catch '$reference_node is a descendant of $self'
  } elsif (rand() < 0.1) {
    $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
  }
```
The command/script running the task should do each task independently, not keeping any datastructure (e.g. array of all bundles, or even sorted nodes) except for the one document. This means that iteration over all nodes should be done again for each task (to simulate the real usage). Don't forget to switch off stdout buffering, so the task names are printed immediately (and timing is accurate).

### Current results
MAXMEM is maximum (virtual) memory (`ps -ovsz`) in MiB.
Other columns are time in seconds. Run on x86_64.
For start, I've selected Romanian (its dev set is one of the smallest files in UD 1.2), later we'll add experiments on bigger files (Czech is the biggest).

`data/UD_Romanian/ro-ud-train.conllu` (632 kB):

experiment|TOTAL |MAXMEM |init |load  |save |iter |iterF|read |write|rehang|remove|add  |reorder|
----------|-----:|------:|----:|-----:|----:|----:|----:|----:|----:|-----:|-----:|----:|------:|
old_Treex |67.788|390.973|1.825|55.963|3.860|0.129|0.045|0.145|0.198|1.320 |1.189 |1.356|0.934  |     
pytreex   | 4.100| 94.637|0.101| 3.318|0.194|0.067|0.021|0.078|0.074|0.170 |0.014 |0.017|0.019  |
cpp_raw   | 0.079|  0    |0.002| 0.011|0.011|0.011|0.010|0.011|0.011|0     |0     |0    |0      |


`data/UD_Czech/cs-ud-train-l.conllu` (68 MB):

experiment|TOTAL |MAXMEM |init |load  |save |iter |iterF|read |write|rehang|remove|add  |reorder|
----------|-----:|------:|----:|-----:|----:|----:|----:|----:|----:|-----:|-----:|----:|------:|
cpp_raw   | 1.614|368.723|0.002| 0.776|0.495|0.013|0.011|0.101|0.056|0     |0     |0    |0      |
