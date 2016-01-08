#!/usr/bin/env perl
use strict;
use warnings;
use UD::Document;
use UD::Node;
use Benchmark qw(:all :hireswallclock);

my $in_conllu = $ARGV[0] || '../data/UD_Czech/cs-ud-train-l.conllu';
my $doc = UD::Document->new();

my @nodes;
my $line = "1\tTatra\tTatra\tPROPN\tNNFS1-----A----\tCase=Nom|Gender=Fem|NameType=Com|Negative=Pos|Number=Sing\t0\troot\t_\tSpaceAfter=No|LId=Tatra-1";
sub _nodes {
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
    for (1..803750){
        my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
        push @nodes, $new_node;
    }
    return;
}

my $bench = timethese(
    10,
    {
        #_chomp      => sub { $doc->_chomp($in_conllu); },
        _splitF      => sub { $doc->_splitF($in_conllu); },
        _split       => sub { $doc->_split($in_conllu); },
        _split_pole  => sub { $doc->_split_pole($in_conllu); },
        _split_reuse => sub { $doc->_split_reuse($in_conllu); },

        
        #_nodes_throwaway_reuse=> sub { $doc->_nodes_throwaway_reuse($in_conllu); },
        #_nodes_throwaway      => sub { $doc->_nodes_throwaway($in_conllu); },
        #_nodes_throwaway_pole => sub { $doc->_nodes_throwaway_pole($in_conllu); },
        #_nodes_array          => sub { $doc->_nodes_array($in_conllu); },
        
        #_nodes_bundles   => sub { $doc->_nodes_bundles($in_conllu); },
    }
);

__END__
