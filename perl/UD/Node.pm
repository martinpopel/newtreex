package UD::Node;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(weaken);

# TODO: 
use Class::XSAccessor {
#my $spec = {
    constructor => 'new',
    setters => { map {("set_$_" => $_)} qw(form lemma upos xpos deprel feats deps misc)},
    getters => {
         (map {($_ => $_)} qw(form lemma upos xpos deprel feats deps misc ord)),
         (map {($_ => "_$_")} qw(parent root)),
     },
};

=pod comment
sub new {
    my $class = shift;
    return bless {@_}, $class;
}

my @ATTRS = qw(form lemma upos xpos deprel feats deps misc);
foreach my $attr (@ATTRS, 'ord'){
    eval "sub $attr {\$_[0]->{$attr}}";
}
foreach my $attr (@ATTRS){
    eval "sub set_$attr {\$_[0]->{$attr} = \$_[1];}";
}

sub parent { $_[0]->{_parent}}

=cut

# use Moo;
# has _parent => (weak_ref => 1,);

my $CHECK_FOR_CYCLES = 1;

sub set_parent {
    my ($self, $parent) = @_;
    confess 'set_parent(undef) not allowed' if !defined $parent;

    if ( $self == $parent || $CHECK_FOR_CYCLES && $parent->is_descendant_of($self) ) {
        my $b_id = $self->bundle->id;
        my $n_id = $self->ord; # TODO id instead of ord?
        my $p_id = $parent->ord;
        confess "Bundle $b_id: Attempt to set parent of $n_id to the node $p_id, which would lead to a cycle.";
    }

    my $orig_parent = $self->{_parent};
    if ($orig_parent){
        $orig_parent->{_children} = [grep {$_ != $self} @{$orig_parent->{_children}}];
    }
    weaken( $self->{_parent} = $parent );
    weaken( $self->{_root} = $parent->{_root} ) if !$self->{_root};
    $parent->{_children} ||= [];
    push @{$parent->{_children}}, $self;  
    return;
}

sub remove {
    my ($self, $arg_ref) = @_;
    if ( $self->is_root ) {
        confess 'Tree root cannot be removed using $root->remove().'
              . ' Use $bundle->remove_tree($selector) instead';
    }

    my @children = $self->children;
    my $parent = $self->{_parent};
    if (@children){
        my $what_to_do = 'remove';
        if ($arg_ref && $arg_ref->{children}){
            $what_to_do = $arg_ref->{children};
        }
        if ($what_to_do =~ /^rehang/){
            foreach my $child (@children){
                $child->set_parent($parent);
            }
        }
        if ($what_to_do =~ /warn$/){
            warn $self->address . " is being removed by remove({children=>$what_to_do}), but it has (unexpected) children";
        }
    }

    # Remove the subtree from the document's indexing table
    my @to_remove = ( $self, $self->descendants );
#   foreach my $node ( @to_remove) {
#         if ( defined $node->id ) {
#             $document->_remove_references_to_node( $node );
#             $document->index_node_by_id( $node->id, undef );
#         }
#     }

    # Disconnect the node from its parent (& siblings) and delete all attributes
    # It actually does: $self->cut(); undef %$_ for ($self->descendants(), $self);
    $parent->{_children} = [grep {$_ != $self} @{$parent->{_children}}];

    # TODO: order normalizing can be done in a more efficient way
    # (update just the following ords)
    #$root->_normalize_node_ordering();

    # By reblessing we make sure that
    # all methods called on removed nodes will result in fatal errors.
    foreach my $node (@to_remove){
        bless $node, 'UD::Node::Removed';
    }
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

sub _descendantsF {
    my ($self) = @_;
    my @descs = ();
    my @stack = $self->children;
    while (@stack) {
        my $node = pop @stack;
        push @descs, $node;
        push @stack, $node->children;
    }
    return @descs;
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

sub is_descendant_of {
    my ($self, $another_node) = @_;
    my $parent = $self->parent;
    while ($parent) {
        return 1 if $parent == $another_node;
        $parent = $parent->parent;
    }
    return 0;
}

sub bundle { $_[0]->{_root}{_bundle}; }

sub document { $_[0]->{_root}{_bundle}{_doc}}

sub address { $_[0]->bundle->id . '-' . $_[0]->ord; } #???

sub is_root { !$_[0]->{_parent}; }


# TODO: How to do this in an elegant way?
# Unless we find a better way, we must disable two perlcritics
package UD::Node::Removed;    ## no critic (ProhibitMultiplePackages)
use Carp;

sub AUTOLOAD {                         ## no critic (ProhibitAutoloading)
    our $AUTOLOAD;
    if ( $AUTOLOAD !~ /DESTROY$/ ) {
        confess "You cannot call any methods on removed nodes, but have called $AUTOLOAD";
    }
}

1;
