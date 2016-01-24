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

sub new {
    my ($class, $attrs) = @_;
    $attrs ||= {};
    $attrs->{_trees} = {};
    return bless $attrs, $class;
}

sub id {$_[0]->{id};}
sub document {$_[0]->{_doc};}

sub trees {
    my ($self) = @_;
    return values %{$self->{_trees}};
}

sub create_tree {
    my ($self, $args) = @_;
    $args ||= {};
    my $selector = $args->{selector} //= '';
    confess "Tree with selector '$selector' already exists" if $self->{_trees}{$selector};
    # TODO $args->{language} ||= 'unk' or even delete $args->{language}
    # TODO reuse the hash $args
    my $class = 'UD::Node' . $self->{_doc}{implementation};
    my $root = $class->new(%$args);
    if ($class eq 'UD::NodeA'){
        $root->[0] = [];
        weaken( $root->[1] = $self );
        weaken( $root->[5] = $root );
        $root->[6] = 0;
    } else {
        weaken( $root->{_root} = $root );
        weaken( $root->{_bundle} = $self );
        $root->{ord} = 0;
    }

    $self->{_trees}{$selector} = $root;
    $root->{_descendants} = [] if $class eq 'UD::NodeClAa';

    return $root;
}

1;
