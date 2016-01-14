#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/";
use Carp;
use Try::Tiny;

my $seed = 42;
my $maxseed = 2**32;
sub myrand {
    my ($modulo) = @_;
    $seed = (1103515245 * $seed + 12345) % $maxseed;
    return $seed % $modulo;
}

STDOUT->autoflush(1);
use UD::Document;
my ($in_conllu, $out_conllu, $implementation) = @ARGV;
print "init\n";

my $doc = UD::Document->new($implementation);
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
            my $rand_index = myrand($#nodes+1);
            # rehanging to a random parent may result in cycles, which should result in exception,
            #try {
            #    $node->set_parent($nodes[$rand_index]);
            #} catch {
            #    confess $_ if !/cycle/; # rethrow other errors than "cycle"
            #};
            # However, try{} catch{} is too slow in Perl, so let's use a special parameter
            $node->set_parent($nodes[$rand_index], {cycles=>'skip'});
        }
    }
}
print "rehang\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            $node->remove if myrand(10)==0 && ref $node ne 'UD::Node::Removed';
        }
    }
}
print "remove\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            if (myrand(10)==0) {
                $node->create_child(form=>'x', lemma=>'x')->shift_after_subtree($node);
            }
        }
    }
}
print "add\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        my @nodes = $tree->descendants;
        foreach my $node (@nodes){
            my $rand_index = myrand($#nodes+1);
            if (myrand(10)==0) {
                #try {
                #    $node->shift_after_node($nodes[$rand_index]);
                #} catch {
                #    confess $_ if !/reference_node is a descendant/;
                #}
                # Again, try{} catch{} is too slow in Perl
                $node->shift_after_node($nodes[$rand_index], {skip_if_descendant=>1});
            } elsif (myrand(10)==0) {
                $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
            }
        }
    }
}
print "reorder\n";
