package Udapi::Core::Bundle;
use strict;
use warnings;
use autodie;
use Carp;
use List::Util qw(any);
use Udapi::Core::Node;

my ($TREES, $ID, $DOC);
BEGIN {
    ($TREES, $ID, $DOC) = (0..10);
}

use Class::XSAccessor::Array {
    constructor => 'new',
    setters => {
        set_id => $ID,
        _set_document => $DOC,
    },
    getters => {
        id => $ID,
        document => $DOC,
    },
};

sub trees { return @{$_[0][$TREES]}; }

sub create_tree {
    my ($self, $args) = @_;
    my $zone = 'und';
    if ($args && $args->{zone}){
        $zone = $args->{zone};
        confess "'$zone' is not a valid zone name" if $zone !~ /^[a-z-]+(_[A-Za-z0-9-])?$/;
        confess "'all' cannot be used as a zone name" if $zone eq 'all';
    }

    if (any {$zone eq $_->zone} @{$self->[$TREES]}) {
        confess "Tree with zone '$zone' already exists in bundle " . $self->id;
    }

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
