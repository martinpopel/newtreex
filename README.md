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
8. **rehang** Rehang each node to a random parent in the same sentence. Method `set_parent` should raise an exception if this would lead to a cycle. Catch such exceptions and leave such nodes under their original parents. Alternatively, there may be a parameter `cycles=skip`, which prevents the exception.
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
MAXMEM is maximum (resident set size) memory (`ps -orss`) in MiB.
Other columns are time in seconds. Run on x86_64.

`data/UD_Czech/cs-ud-train-l.conllu` (68 MB):

experiment|TOTAL   |MAXMEM   |init |load    |save   |iter  |iterF|read  |write |rehang|remove|add   |reorder|
----------|-------:|--------:|----:|-------:|------:|-----:|----:|-----:|-----:|-----:|-----:|-----:|------:|
old_Treex |4646.216|18114.070|2.583|3881.600|334.891|12.311|4.471|14.577|18.026|89.175|86.787|76.207|57.576 |     
pytreex   | 215.912| 3731.938|0.109| 177.463| 10.543| 3.199|1.235| 3.843| 3.610| 7.676| 0.161| 0.162| 0.165 |     
perl_plain|  60.794| 1068.227|0.077|  17.065|  6.024| 1.947|1.295| 2.477| 2.352| 6.972| 5.557| 6.031| 8.511 |     
java      |   9.105| 1655.184|0.121|   3.451|  2.651| 0.231|0.223| 0.363| 0.229| 0.274| 0.309| 0.461| 0.590 |
cpp_raw   |   3.090|  356.359|0.004|   1.148|  0.976| 0.041|0.034| 0.249| 0.175|skip  |skip  |skip  |skip   |     


#### Comments:
* `cpp_raw` does not implement rehang, remove, add, reorder yet.
* `pytreex` probably fails if removing a node with children, but no error is printed. This task and the following ones have suspiciously fast times.
