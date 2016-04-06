package Udapi::Block::Dummy;
use Udapi::Core::Common;
extends 'Udapi::Core::Block';

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