package Udapi::Core::Bundle;
use strict;
use warnings;
use autodie;
use Carp;
use Udapi::Core::Node;

my ($TREES, $ID, $DOC);
BEGIN {
    ($TREES, $ID, $DOC) = (0..10);
}

use Class::XSAccessor::Array {
    constructor => 'new',
    setters => {
        set_id => $ID,
    },
    getters => {
        id => $ID,
        document => $DOC,
    },
};

sub set_document { $_[0][$DOC] = $_[1]; }

sub trees { return @{$_[0][$TREES]}; }

sub create_tree {
    my ($self) = @_;
    # TODO: $args->{after}
    #$args ||= {};
    #my $selector = $args->{selector} //= '';
    #confess "Tree with selector '$selector' already exists" if $self->{_trees}{$selector};
    #$args->{language} ||= 'unk'
    my $root = Udapi::Core::Node->_create_root($self);
    push @{$self->[$TREES]}, $root;
    return $root;
}

sub destroy {
    my ($self) = @_;
    foreach my $tree (@{$self->[$TREES]}){
        $tree->destroy();
    }
    undef @$self;
    return;
}

1;
