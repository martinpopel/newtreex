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

=for comment
$doc->_chomp($in_conllu);
print "_chomp\n";

$doc->_comments($in_conllu);
print "_comments\n";

$doc->_splitPole($in_conllu);
print "_splitPole\n";

$doc->_splitF($in_conllu);
print "_splitF\n";

$doc->_split($in_conllu);
print "_split\n";

my @nodes;
my $line = "1\tTatra\tTatra\tPROPN\tNNFS1-----A----\tCase=Nom|Gender=Fem|NameType=Com|Negative=Pos|Number=Sing\t0\troot\t_\tSpaceAfter=No|LId=Tatra-1";
my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
for (1..803750){
    my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
    push @nodes, $new_node;
}
print "p_nodes\n";
undef @nodes;
print "_d\n";

for (1..803750){
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
    my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
    push @nodes, $new_node;
}
print "p_nodes_split\n";
undef @nodes;
print "_d\n";

open my $fh, '<:utf8', $in_conllu;
while (my $line = <$fh>) {
    chomp $line;
    next if $line eq '' or $line =~ /^#/;
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
    my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
    push @nodes, $new_node;
}
close $fh;
print "p_nodes_split_read\n";
undef @nodes;
print "_d\n";

$doc->_nonodes($in_conllu);
print "_nonodes\n";
$doc->{_bundles} = [];
print "_d\n";

$doc->_norehang($in_conllu);
print "_norehang\n";
$doc->{_bundles} = [];
print "_d\n";

$doc->_nodesonly($in_conllu);
print "_nodesonly\n";
$doc->{_bundles} = [];
print "_d\n";

=cut

$doc->load_conlluF($in_conllu);
print "loadF\n";
$doc->{_bundles} = [];
print "_d\n";

$doc->load_conlluFnosetparent($in_conllu);
print "loadFnosetparent\n";
$doc->{_bundles} = [];
print "_d\n";

$doc->load_conllu_nocheck($in_conllu);
print "load_nocheck\n";
$doc->{_bundles} = [];
print "_d\n";

$doc->load_conllu_nocheck2($in_conllu);
print "load_nocheck2\n";
$doc->{_bundles} = [];
print "_d\n";


$doc->load_conllu($in_conllu);
print "load\n";

__END__

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
            my $rand_index = int(rand($#nodes+1));
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
            $node->remove if rand() < 0.1 && ref $node ne 'UD::Node::Removed';
        }
    }
}
print "remove\n";

foreach my $bundle ($doc->bundles){
    foreach my $tree ($bundle->trees){
        foreach my $node ($tree->descendants){
            if (rand() < 0.1) {
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
            my $rand_index = int(rand($#nodes+1));
            if (rand() < 0.1) {
                #try {
                #    $node->shift_after_node($nodes[$rand_index]);
                #} catch {
                #    confess $_ if !/reference_node is a descendant/;
                #}
                # Again, try{} catch{} is too slow in Perl
                $node->shift_after_node($nodes[$rand_index], {skip_if_descendant=>1});
            } elsif (rand() < 0.1) {
                $node->shift_before_subtree($nodes[$rand_index], {without_children=>1});
            }
        }
    }
}
print "reorder\n";
