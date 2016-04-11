package Udapi::Block::Write::Sentences;
use Udapi::Core::Common;
extends 'Udapi::Core::Block';

sub process_tree {
    my ($self, $tree) = @_;
    say $tree->sentence;
    return;
}

1;
