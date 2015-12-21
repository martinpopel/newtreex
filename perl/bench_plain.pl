#!/usr/bin/env perl
use strict;
use warnings;
STDOUT->autoflush(1);
use UD::Document;
my ($in_conllu, $out_conllu) = @ARGV;
print "init\n";

my $doc = UD::Document->new();
$doc->load_conllu($in_conllu);
print "load\n";

$doc->save_conllu($out_conllu);
print "save\n";

__END__


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
                my $rand_index = int(rand($#nodes+1));
                $node->set_parent($nodes[$rand_index]);
            }
        }
    }
}
print "rehang\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            $node->remove if rand() < 0.1 && ref $node ne 'Treex::Core::Node::Deleted';
        }
    }
}
print "remove\n";

foreach my $bundle ($doc->get_bundles()){
    foreach my $tree ($bundle->get_all_trees()){
        foreach my $node ($tree->get_descendants({ordered=>1})){
            if (rand() < 0.1) {
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
            if (rand() < 0.1) {
                # Catch an exception if $nodes[$rand_index] is a descendant of $node
                local $SIG{__WARN__} = sub {};
                eval {
                    $node->shift_after_node($nodes[$rand_index]);
                }
            } elsif (rand() < 0.1) {
                $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
            }
        }
    }
}
print "reorder\n";
