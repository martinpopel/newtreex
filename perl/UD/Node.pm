package UD::Node;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(weaken);
my @ATTRS = qw(form lemma upos xpos deprel feats misc);

# TODO: 
#use Class::XSAccessor {
my $spec = {
    constructor => 'new',
    setters => { map {("set_$_" => $_)} @ATTRS},
    getters => {
        (map {($_ => $_)} @ATTRS, 'ord'),
        (map {($_ => "_$_")} qw(parent root)),
    },
};

sub new {
    my $class = shift;
    return bless {@_}, $class;
}

foreach my $attr (@ATTRS, 'ord'){
    eval "sub $attr {\$_[0]->{$attr}}";
}

sub parent { $_[0]->{_parent}}


# use Moo;
# has _parent => (weak_ref => 1,);

sub set_parent {
    my ($self, $parent) = @_;
    confess 'set_parent(undef) not allowed' if !defined $parent;
    my $orig_parent = $self->{_parent};
    if ($orig_parent){
        $orig_parent->{_children} = [grep {$_ != $self} @{$orig_parent->{_children}}]
    }
    weaken( $self->{_parent} = $parent );
    weaken( $self->{_root} = $parent->{_root} );
    $parent->{_children} ||= [];
    push @{$parent->{_children}}, $self;  
    return;
}

sub create_child {
    my $self = shift;
    my $child = UD::Node->new(@_); #ref($self)->new(@_);
    $child->set_parent($self);
    return $child;
}

sub children {
    my ($self) = @_;
    my $ch = $self->{_children};
    return $ch ? @$ch : ();
}

sub descendants {
    my ($self) = @_;
    my @descs = ();
    my @stack = $self->children;
    while (@stack) {
        my $node = pop @stack;
        push @descs, $node;
        push @stack, $node->children;
    }
    return sort {$a->{ord} <=> $b->{ord}} @descs;
}

1;
