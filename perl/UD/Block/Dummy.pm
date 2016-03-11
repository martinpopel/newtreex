package UD::Block::Dummy;
use UD::Core::Common;
extends 'UD::Core::Block';

binmode STDOUT, 'utf8';

sub process_tree {
    my ($self, $root) = @_;
    say join ' ', map {$_->form} $root->descendants;
    #p($root);
    return;
}

sub process_node {
    my ($self, $node) = @_;
    print $node->lemma."\n";
    return;
}

1;