package UD::Bundle;
use strict;
use warnings;
use autodie;
use Carp;
use Scalar::Util qw(weaken);
use UD::NodeCa;
use UD::NodeCl;
use UD::NodeClAa;
use UD::NodeClAl;
use UD::NodeA;

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

sub set_document { weaken( $_[0][$DOC] = $_[1]); }

sub trees { return @{$_[0][$TREES]}; }

sub create_tree {
    my ($self) = @_;
    # TODO: $args->{after}
    #$args ||= {};
    #my $selector = $args->{selector} //= '';
    #confess "Tree with selector '$selector' already exists" if $self->{_trees}{$selector};
    #$args->{language} ||= 'unk'
    my $class = 'UD::Node' . $self->[$DOC]{implementation};
    my $root = $class->_create_root($self);
    push @{$self->[$TREES]}, $root;
    return $root;
}

1;
