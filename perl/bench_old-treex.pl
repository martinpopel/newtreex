#!/usr/bin/env perl
use strict;
use warnings;
use Treex::Block::Read::CoNLLU;
use Treex::Block::Write::CoNLLU;
use Treex::Core::Log;
Treex::Core::Log::log_set_error_level('WARN');

STDOUT->autoflush(1);
$SIG{INT} = sub {warn "\nbench.pl is ignoring Ctrl+C (SIGINT). Use Ctrl+\\ (SIGQUIT) to exit\n";};

my $seed = 42;
my $maxseed = 2**32;
sub myrand {
    my ($modulo) = @_;
    $seed = (1103515245 * $seed + 12345) % $maxseed;
    return $seed % $modulo;
}

my ($in_conllu, $out_conllu) = @ARGV;
print "init\n";

my $reader = Treex::Block::Read::CoNLLU->new({from=>$in_conllu});
my $doc = $reader->next_document();
print "load\n";

my $writer = Treex::Block::Write::CoNLLU->new({to=>$out_conllu});
$writer->process_document($doc);
print "save\n";

foreach my $bundle ($doc->get_bundles()){
    # There is just one tree in each bundle, but let's make the code more general
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            # no op
        }
    }
}
print "iter\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants()){
            # no op
        }
    }
}
print "iterF\n";


foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            my $form_lemma = $node->form . $node->lemma;
        }
    }
}
print "read\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            $node->set_conll_deprel('dep');
        }
    }
}
print "write\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        my @nodes = $tree->get_descendants({ordered=>1});
        foreach my $node (@nodes){
            # rehanging to a random parent may result in cycles, which should result in exception
            # eval {} is the pure-Perl way of try-catch.
            # Let's also prevent the TREEX-FATAL messages on stderr
            local $SIG{__WARN__} = sub {};
            eval {
                my $rand_index = myrand($#nodes+1);
                $node->set_parent($nodes[$rand_index]);
            }
        }
    }
}
print "rehang\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            $node->remove if myrand(10)==0 && ref $node ne 'Treex::Core::Node::Deleted';
        }
    }
}
print "remove\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            if (myrand(10)==0) {
                $node->create_child({form=>'x', lemma=>'x'})->shift_after_subtree($node);
            }
        }
    }
}
print "add\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        my @nodes = $tree->get_descendants({ordered=>1});
        foreach my $node (@nodes){
            my $rand_index = int(rand($#nodes+1));
            if (myrand(10)==0) {
                # Catch an exception if $nodes[$rand_index] is a descendant of $node
                local $SIG{__WARN__} = sub {};
                eval {
                    $node->shift_after_node($nodes[$rand_index]);
                }
            } elsif (myrand(10)==0) {
                $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
            }
        }
    }
}
print "reorder\n";
