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
8. **rehang** Rehang each node to a random* parent in the same sentence. Method `set_parent` should raise an exception if this would lead to a cycle. Catch such exceptions and leave such nodes under their original parents. Alternatively, there may be a parameter `cycles=skip`, which prevents the exception.
9. **remove** Delete random 10% of nodes. That is `if (myrand(10)==0){ $node->remove()}`, so it does not need to be exactly 10%. Removing a node by default removes all its descendants. (Note that if you iterate over a list of original nodes, you may encounter already deleted nodes. You should check this case and don't try to delete already deleted nodes.)
10. **add** Select random 10% of nodes (as above) and add a child under them (*lemma*=x, *form*=x). It should be the last child according to word order (and last=rightmost descendant).
11. **reorder** Shift 10% of nodes (with their whole subtree) after random node (except when that random node is a descendant). From the rest of the nodes, shift 10% of nodes without their subtree before a random subtree. That is:
```
  my $rand_index = myrand($#nodes+1);
  if (myrand(10)==0){
    try{$node->shift_after_node($nodes[$rand_index]);}
    # catch '$reference_node is a descendant of $self'
  } elsif (myrand(10)==0) {
    $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
  }
```
*) For selecting random node and random 10% in tasks 8-11, use an equivalent of the following function `myrand`, so it is deterministic and replicable accross different programming languages.
```
my $seed = 42;
my $maxseed = 2**32;
sub myrand {
    my ($modulo) = @_;
    $seed = (1103515245 * $seed + 12345) % $maxseed;
    return $seed % $modulo;
}
```

The command/script running the task should do each task independently, not keeping any datastructure (e.g. array of all bundles, or even sorted nodes) except for the one document. This means that iteration over all nodes should be done again for each task (to simulate the real usage). Don't forget to switch off stdout buffering, so the task names are printed immediately (and timing is accurate).

### Results
MAXMEM is maximum (resident set size) memory (`ps -orss`) in MiB.
Other columns are time in seconds. Run on x86_64.

`data/UD_Czech/cs-ud-train-l.conllu` (68 MB):

experiment    |TOTAL   |MAXMEM   |init |load    |save   |iter |iterF|read |write |rehang|remove|add   |reorder|
--------------|-------:|--------:|----:|-------:|------:|----:|----:|----:|-----:|-----:|-----:|-----:|------:|
old_Treex     |2989.996|18023.746|2.772|2501.309|201.291|7.647|3.169|9.185|11.618|55.882|58.347|47.265|35.765 
pytreex       | 257.175| 3839.100|0.116| 177.631| 12.327|3.154|1.223|3.794| 3.572| 9.180| 5.520|21.544|13.349 
perl_plain    |  54.865| 1057.981|0.103|  10.784|  6.128|1.951|1.249|2.477| 2.339| 6.734| 5.776| 6.261| 8.604 
java          |   8.937| 1647.544|0.125|   3.432|  2.224|0.245|0.390|0.472| 0.230| 0.272| 0.311| 0.462| 0.569 
cpp_raw       |   3.183|  356.363|0.004|   1.137|  1.076|0.041|0.034|0.249| 0.175| skip | skip |skip  |skip  

#### Comments:
* `cpp_raw` does not implement rehang, remove, add, reorder yet.
* More details (and newer results) are at the [GitHub wiki](https://github.com/martinpopel/newtreex/wiki/Home)
