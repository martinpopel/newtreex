#!/usr/bin/env perl
use strict;
use warnings;
#use Scalar::Util qw(weaken);

STDOUT->autoflush(1);

my ($DESC, $DOC, $FIRST, $NEXT, $ROOT, $PARENT) = (0..10);

foreach my $rep (1..15){
    my $doc = [];
    foreach my $t (1..100){
        my $root = $doc->[$t] = [];
        $root->[$DOC] = $doc;
#weaken($root->[$DOC]);
        $root->[$ROOT] = $root;
        my @nodes = map {['x' x 9999]} (1..30);
        $nodes[0][$ROOT] = $root;
        $root->[$FIRST] = $nodes[0];
        $root->[$DESC] = \@nodes;
        foreach my $n (1..$#nodes){
            $nodes[$n]->[$PARENT] = $root;
#weaken($nodes[$n]->[$PARENT]);
            $nodes[$n]->[$ROOT] = $root;
            $nodes[$n-1][$NEXT] = $nodes[$n];
        }
    }
    print "load\n";

    destroy($doc);
    undef $doc;
    print "free\n";
}

sub destroy {
    my ($doc) = @_;
    foreach my $root (@$doc){
#        foreach my $node ($root->[$DESC]){
#           undef @$node;
#        }
        undef @$root;
    }
    return;
}
