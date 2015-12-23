#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/";
use Carp;
use Try::Tiny;

STDOUT->autoflush(1);
use UD::Document;
my ($in_conllu, $out_conllu) = @ARGV;
print "init\n";

my $doc = UD::Document->new();
$doc->load_conllu($in_conllu);
print "load\n";

$doc->save_conllu($out_conllu);
print "save\n";

foreach my $bundle ($doc->bundles){
    # There is just one tree in each bundle, but let's make the code more general
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            # no op
        }
    }
}
print "iter\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->_descendantsF){
            # no op
        }
    }
}
print "iterF\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            my $form_lemma = $node->form . $node->lemma;
        }
    }
}
print "read\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            $node->set_deprel('dep');
        }
    }
}
print "write\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        my @nodes = $tree->descendants;
        foreach my $node (@nodes){
            # rehanging to a random parent may result in cycles, which should result in exception
            try {
                my $rand_index = int(rand($#nodes+1));
                $node->set_parent($nodes[$rand_index]);
            } catch {
                confess $_ if !/cycle/; # rethrow other errors than "cycle"
            };
        }
    }
}
print "rehang\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            $node->remove if rand() < 0.1 && ref $node ne 'UD::Node::Removed';
        }
    }
}
print "remove\n";

__END__

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
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
