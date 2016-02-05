#!/usr/bin/env perl
use v5.10;
use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/";
use POSIX ();
use Carp;

$SIG{INT} = sub {warn "\nbench.pl is ignoring Ctrl+C (SIGINT). Use Ctrl+\\ (SIGQUIT) to exit\n";};

my $seed = 42;
my $maxseed = 2**32;
sub myrand {
    $seed = (1103515245 * $seed + 12345) % $maxseed;
    return $seed % $_[0];
}

STDOUT->autoflush(1);
use UD::Document;

my $DEBUG = 0;
if ($ARGV[0] eq '-d'){
    shift @ARGV;
    $DEBUG = 1;
}
my $ITERS = 1;
if ($ARGV[0] eq '-n'){
    shift @ARGV;
    $ITERS = shift @ARGV;
}

my ($in_conllu, $out_conllu, $implementation) = @ARGV;
print "init\n";

for my $iter (1..$ITERS){
    my $doc = UD::Document->new($implementation);
    $doc->load_conllu($in_conllu);
    print "load\n";
    $doc->save_conllu("perl$implementation-load.conllu") if $DEBUG;

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
            foreach my $child ($tree->children){
                foreach my $node ($child->descendants){
                    # no op
                }
            }
        }
    }
    print "iterS\n";

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
    $doc->save_conllu("perl$implementation-write.conllu") if $DEBUG;

    my $cycles_skip = {cycles=>'skip'};
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
                $node->set_parent($nodes[$rand_index], $cycles_skip);
            }
        }
    }
    print "rehang\n";
    $doc->save_conllu("perl$implementation-rehang.conllu") if $DEBUG;

    foreach my $bundle ($doc->bundles){
        foreach my $tree ($bundle->trees){
            foreach my $node ($tree->descendants){
                $node->remove if myrand(10)==0 && ref $node ne 'UD::Node::Removed';
            }
        }
    }
    print "remove\n";
    $doc->save_conllu("perl$implementation-remove.conllu") if $DEBUG;

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
    $doc->save_conllu("perl$implementation-add.conllu") if $DEBUG;

    my ($skip_if_descendant, $without_children) = ({skip_if_descendant=>1}, {without_children=>1});
    foreach my $bundle ($doc->bundles){
        foreach my $tree ($bundle->trees){
            my @nodes = $tree->descendants;
            foreach my $node (@nodes){
                my $rand_index = myrand($#nodes+1);
                if (myrand(10)==0) {
                    $node->shift_after_node($nodes[$rand_index], $skip_if_descendant);
                } elsif (myrand(10)==0) {
                    $node->shift_before_subtree($nodes[$rand_index], $without_children);
                }
            }
        }
    }
    print "reorder\n";
    $doc->save_conllu("perl$implementation-reorder.conllu") if $DEBUG;

    $doc->save_conllu($out_conllu);
    print "save\n";

    # no need to call destroy in the last iteration
    last if $iter == $ITERS;

    $doc->destroy;
    print "free\n";
}

print "end\n";

# No need for Perl running DESTROY and waiting for buffered outputs
POSIX::_exit(0);