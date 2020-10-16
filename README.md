# New Treex
Experiments with efficient API for processing dependency trees (new version of [Treex](https://github.com/ufal/treex)).

## Benchmark
First, run `make data` to download [UD 1.2](http://hdl.handle.net/11234/1-1548) and store in `data` directory.
See definition of the [CoNLL-U](https://universaldependencies.github.io/docs/format.html) data format.
Add your implementation of the New Treex API (TODO: add a link to the specification) in a directory named by the programming language of your choice (python, perl, java, c,...).
Add possible compilation into the [Makefile](Makefile).
Edit `@COMMANDS` in [benchmark.pl](benchmark.pl) so it calls a command which runs the benchmark on selected treebanks.
For correct memory consumption statistics the command should not contain shell metacharacters and it should not execute any child process.
The command may contain options to run different version of your implementation (e.g. prioritizing speed over memory).
Finally, run `make benchmark`.

The benchmark command should do several tasks and after finishing each task print the task name on STDOUT.
Nothing else should be printed on STDOUT. The tasks are:

1. **init** Intialize whatever is needed.
2. **load** Load the CoNLL-U file (specified as the first parameter) to memory.
3. **iter** Iterate over all nodes in all sentences by their word order.
4. **iterF** Iterate over all nodes (fast). Nodes within one sentence may be iterated in any order.
5. **iterS** Iterate over all (sorted) descendants of all (sorted) children of the root. Some implementations have faster `descendants()` if called on the root, so this task should evaluate the difference.
6. **iterN** Take the root and iterate over all (sorted) nodes by calling `next_node()` in a while cycle.
7. **read** Iterate over all nodes (sorted, this holds for the rest of the tasks) and create a variable with concatenated *form* and *lemma*.
8. **write** Set `deprel` attribute of each node to the value `dep`.
9. **rehang** Rehang each node to a random* parent in the same sentence. Method `set_parent` should raise an exception if this would lead to a cycle. Catch such exceptions and leave such nodes under their original parents. Alternatively, there may be a parameter `cycles=skip`, which prevents the exception.
10. **remove** Delete random 10% of nodes. That is `if (myrand(10)==0){ $node->remove()}`, so it does not need to be exactly 10%. Removing a node by default removes all its descendants. (Note that if you iterate over a list of original nodes, you may encounter already deleted nodes. You should check this case and don't try to delete already deleted nodes.)
11. **add** Select random 10% of nodes (as above) and add a child under them (*lemma*=x, *form*=x). It should be the last child according to word order (and last=rightmost descendant).
12. **reorder** Shift 10% of nodes (with their whole subtree) after a random node (except when that random node is a descendant). From the rest of the nodes, shift 10% of nodes without their subtree before a random subtree.**
13. **save** Save the in-memory document to an output CoNLL-U file (specified as the second parameter).

*) For selecting random node and random 10% in tasks 9-12, use an equivalent of the following function `myrand`, so it is deterministic and replicable accross different programming languages.
```
my $seed = 42;
my $maxseed = 2**32;
sub myrand {
    my ($modulo) = @_;
    $seed = (1103515245 * $seed + 12345) % $maxseed;
    return $seed % $modulo;
}
```

**) The code for task 10 (reorder) is:
```
  # for each $tree
  my @nodes = $tree->descendants;
  # The order of the following two lines is IMPORTANT for replicability.
  my $rand_index = myrand($#nodes+1);
  if (myrand(10)==0){
    try{$node->shift_after_node($nodes[$rand_index]);}
    # catch '$reference_node is a descendant of $self'
  } elsif (myrand(10)==0) {
    $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
  }
```

The command/script running the task should do each task independently, not keeping any datastructure (e.g. array of all bundles, or even sorted nodes) except for the one document. This means that iteration over all nodes should be done again for each task (to simulate the real usage). Don't forget to switch off stdout buffering, so the task names are printed immediately (and timing is accurate).

If the script is executed with `-d` (debug), it should save the document into conll files after all task which modify the document (load, write, rehang, remove, add, reorder). The filenames should contain implementation name and task name, e.g. `pytreex-load.conllu`, `pytreex-write.conllu`,... and they should be saved in the current directory.

### Results
MAXMEM is maximum (resident set size) memory (`ps -orss`) in MiB.
Other columns are time in seconds. Run on x86_64.

`data/UD_Czech/cs-ud-train-l.conllu` (68 MB):
REPEATS=10 hostname=tauri2

experiment|REAL   |CPU    |MAXMEM  |init |load   |save |iter |iterF|iterS|iterN |read |write|rehang|remove|add   |reorder|exit |RSD
----------|------:|------:|-------:|----:|------:|----:|----:|----:|----:|-----:|----:|----:|-----:|-----:|-----:|------:|----:|----:
old_Treex |2989.996|    ?|18023.746|2.772|2501.309|201.291|7.647|3.169| ?|     ?|9.185|11.618|55.882|58.347|47.265|35.765|    ?|?
pytreex   |240.090|240.039|3808.691|0.097|158.064|7.869|2.851|0.990|0.977|15.217|3.291|3.111|7.348 |8.918 |17.059|11.215 |3.086|0.003
utreex    | 45.508| 45.471| 879.117|0.029| 24.096|5.657|0.143|0.142|0.744| 1.726|0.373|0.267|4.579 |2.240 | 3.049| 1.215 |1.248|0.005
perl      | 20.646| 20.601| 748.066|0.077|  6.793|2.932|0.193|0.185|1.069| 0.589|0.617|0.524|2.441 |2.067 | 1.259| 1.863 |0.039|0.004
java      | 14.365| 36.185|1323.910|0.099|  8.636|0.913|0.309|0.204|0.219| 1.389|0.309|0.227|0.322 |0.487 | 0.446| 0.740 |0.066|0.014

#### Comments:
* `cpp_raw` does not implement rehang, remove, add, reorder yet.
* More details (and newer results) are at the [GitHub wiki](https://github.com/martinpopel/newtreex/wiki/Home)
