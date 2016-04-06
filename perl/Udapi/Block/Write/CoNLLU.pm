package Udapi::Block::Write::CoNLLU;
use Udapi::Core::Common;
extends 'Udapi::Core::Block';

binmode STDOUT, 'utf8';

sub process_tree {
    my ($self, $tree) = @_;
    my @nodes = $tree->descendants;

    # Empty sentences are not allowed in CoNLL-U.
    return if !@nodes;

    my $comment = $tree->misc;
    if (length $comment){
        chomp $comment;
        $comment =~ s/\n/\n#/g;
        say "#", $comment;
    }
    foreach my $node (@nodes){
        say join("\t", map {(defined $_ and $_ ne '') ? $_ : '_'}
            $node->ord, $node->form, $node->lemma, $node->upos, $node->xpos,
            $node->feats, $node->parent->ord, $node->deprel, $node->deps, $node->misc);
    }
    print "\n";
    return;
}

1;
