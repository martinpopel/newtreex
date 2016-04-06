#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use FindBin;
use lib "$FindBin::Bin/";
binmode(STDERR, ":utf8");
#STDOUT->autoflush(1);

use Udapi::Core::Document;

#warn "start";
foreach my $rep (1..1){
    warn "new";
    my $doc = Udapi::Core::Document->new('A');
    warn "start_load";
    $doc->load_conllu('../t.conllu');
    warn "end_load";

    foreach my $bundle ($doc->bundles){
        foreach my $tree ($bundle->trees){
            warn "ROOT $tree\n";
            foreach my $node ($tree->descendants){
                warn "$node " . ($node->[6]//'').($node->[8] // '')."\n";
            }
        }
    }
    warn "destroy";
    $doc->destroy();
    warn "end scope";
}

warn "end prog";
