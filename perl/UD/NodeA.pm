package UD::NodeA;
use strict;
use warnings;
use Carp qw(confess cluck);
use Scalar::Util qw(weaken);
use List::Util qw(first);

my @ATTRS;
my ($DESCENDANTS, $BUNDLE, $FIRSTCHILD, $NEXTSIBLING, # private (no getter nor setter)
    $PARENT, $ROOT, $ORD,                    # public getter
    $FORM, $LEMMA, $UPOS, $XPOS, $FEATS, $DEPREL, $DEPS, $MISC);
BEGIN {
    @ATTRS = qw(descendants bundle firstchild nextsibling
            parent root ord
            form lemma upos xpos feats deprel deps misc);
    ($DESCENDANTS, $BUNDLE, $FIRSTCHILD, $NEXTSIBLING,
    $PARENT, $ROOT, $ORD,
    $FORM, $LEMMA, $UPOS, $XPOS, $FEATS, $DEPREL, $DEPS, $MISC)
    = (0..$#ATTRS);
}

use Class::XSAccessor::Array {
    setters => { map {('set_'.$ATTRS[$_] => $_)} ($FORM..$MISC) },
    getters => { map {(       $ATTRS[$_] => $_)} ($PARENT..$MISC) },
};

sub new {
    my ($class, %h) = @_;
    my $array = [ map {$h{$_}} @ATTRS];
    return bless $array, $class;
}

sub set_parent {
    my ($self, $parent, $args) = @_;
    confess('set_parent(undef) not allowed') if !defined $parent;

    if ( ($self == $parent || $parent->is_descendant_of($self) )) {
        return if $args && $args->{cycles} eq 'skip';
        my $b_id = $self->bundle->id;
        my $n_id = $self->ord; # TODO id instead of ord?
        my $p_id = $parent->ord;
        confess "Bundle $b_id: Attempt to set parent of $n_id to the node $p_id, which would lead to a cycle.";
    }

    $self->cut() if $self->[$PARENT];

    weaken( $self->[$PARENT] = $parent );
    if (!$self->[$ROOT]){
        my $root = $parent->[$ROOT];
        weaken( $self->[$ROOT] = $root );
        push @{$root->[$DESCENDANTS]}, $self;
    }

    $self->[$NEXTSIBLING] = $parent->[$FIRSTCHILD];
    $parent->[$FIRSTCHILD] = $self;
    return;
}

sub cut {
    my ($self) = @_;
    my $parent = $self->[$PARENT];
    my $node = $parent->[$FIRSTCHILD];
    if ($self == $node) {
        $parent->[$FIRSTCHILD] = $self->[$NEXTSIBLING];
    } else {
        while ($node && $self != $node->[$NEXTSIBLING]){
            $node = $node->[$NEXTSIBLING];
        }
        $node->[$NEXTSIBLING] = $self->[$NEXTSIBLING] if $node;
    }
    $self->[$PARENT] = $self->[$NEXTSIBLING] = undef;
    return $self;
}

sub remove {
    my ($self, $arg_ref) = @_;
    my $root = $self->[$ROOT];
    if ( $root == $self ) {
        confess 'Tree root cannot be removed using $root->remove().'
              . ' Use $bundle->remove_tree($selector) instead';
    }

    my @children = $self->children;
    my $parent = $self->[$PARENT];
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

    my @to_remove = sort {$a->[$ORD] <=> $b->[$ORD]} ($self, $self->_descendantsF);
    my ($first_ord, $last_ord) = ($to_remove[0]->[$ORD], $to_remove[-1]->[$ORD]);
    my $all_nodes = $root->[$DESCENDANTS];

    # Remove the nodes from $root->[$DESCENDANTS].
    # projective subtrees can be deleted faster
    if ($last_ord - $first_ord + 1 == @to_remove){
        splice @{$root->[$DESCENDANTS]}, $first_ord - 1, $last_ord - $first_ord + 1;
    }
    # non-projective subtrees must iterated
    else {
        my $remove_i = 1;
        my @new_all_nodes = @$all_nodes[0..$first_ord-2];
        for my $all_i ($first_ord .. $#{$all_nodes}){
            if (($to_remove[$remove_i]||0) == $all_nodes->[$all_i]){
                $remove_i++;
            } else {
                push @new_all_nodes, $all_nodes->[$all_i];
            }
        }
        $root->[$DESCENDANTS] = $all_nodes = \@new_all_nodes
    }

    # Update ord of the following nodes in the tree
    for my $i ($first_ord-1..$#{$all_nodes}){
        $all_nodes->[$i]->[$ORD] = $i+1;
    }

    # Disconnect the node from its parent (& siblings) and delete all attributes
    $self->cut();

    # By reblessing we make sure that
    # all methods called on removed nodes will result in fatal errors.
    foreach my $node (@to_remove){
        bless $node, 'UD::Node::Removed';
    }
    return;
}

sub children {
    my ($self) = @_;
    my @children = ();
    my $child = $self->[$FIRSTCHILD];
    while ($child) {
        push @children, $child;
        $child = $child->[$NEXTSIBLING];
    }
    return @children;
}

sub create_child {
    my $self = shift;
    my $child = UD::NodeA->new(@_); #ref($self)->new(@_);
    $child->set_parent($self);
    return $child;
}

sub _descendantsF {
    my ($self) = @_;
    return @{$self->[$DESCENDANTS]} if $self->[$DESCENDANTS];
    my @descs = ();
    my @stack = $self->[$FIRSTCHILD] || ();
    while (@stack) {
        my $node = pop @stack;
        push @descs, $node;
        push @stack, $node->[$NEXTSIBLING] || ();
        push @stack, $node->[$FIRSTCHILD] || ();
    }
    return @descs;
}

sub descendants {
    my ($self, $args) = @_;
    if ($self->[$DESCENDANTS]){
        return @{$self->[$DESCENDANTS]} if !$args;
        if (!$args->{except}){
            if ($args->{first_only}){
                return $self if $args->{add_self};
                return $self->[$DESCENDANTS][0];
            }
            return $self->[$DESCENDANTS][-1] if $args->{last_only};
            return @{$self->[$DESCENDANTS]}; # unknown arg
        }
    }

    my $except = $args ? ($args->{except}||0) : 0;
    return () if $self == $except;
    my @descs = ();
    my @stack = $self->[$FIRSTCHILD] || ();
    my $node;
    while (@stack) {
        $node = pop @stack;
        push @stack, $node->[$NEXTSIBLING] || ();
        next if $node == $except;
        push @descs, $node;
        push @stack, $node->[$FIRSTCHILD] || ();
    }

    # TODO nicer code
    if ($args){
        push @descs, $self if $args->{add_self};
        if ($args->{first_only}){
            my ($first) = sort {$a->[$ORD] <=> $b->[$ORD]} @descs;
            return $first;
        }
        if ($args->{last_only}){
            my ($last) = sort {$b->[$ORD] <=> $a->[$ORD]} @descs;
            return $last;
        }
    }

    # TODO ord is undef when $n->create_child()->shift_after_subtree($n);
    return sort {($a->[$ORD]||0) <=> ($b->[$ORD]||0)} @descs;
}

sub is_descendant_of {
    my ($self, $another_node) = @_;
    return 0 if !$another_node->[$FIRSTCHILD];
    my $parent = $self->[$PARENT];
    while ($parent) {
        return 1 if $parent == $another_node;
        $parent = $parent->[$PARENT];
    }
    return 0;
}

sub bundle { $_[0]->[$ROOT]{_bundle}; }

sub document { $_[0]->[$ROOT]{_bundle}{_doc}}

sub address { $_[0]->bundle->id . '-' . $_[0]->[$ORD]; } #???

sub is_root { !$_[0]->[$PARENT]; }

sub log_fatal { confess @_; }
sub log_warn { cluck @_; }

sub _check_shifting_method_args {
    my ( $self, $reference_node, $arg_ref ) = @_;
    my @c     = caller 1;
    my $stack = "$c[3] called from $c[1], line $c[2]";
    log_fatal( 'Incorrect number of arguments for ' . $stack ) if @_ < 2 || @_ > 3;
    log_fatal( 'Undefined reference node for ' . $stack ) if !$reference_node;
    log_fatal( 'Reference node must be from the same tree. In ' . $stack )
        if $reference_node->root != $self->root;

    if (!$arg_ref->{without_children} && $reference_node->is_descendant_of($self)){
        return 1 if $arg_ref->{skip_if_descendant};
        log_fatal '$reference_node is a descendant of $self.'
                . ' Maybe you have forgotten {without_children=>1}. ' . "\n" . $stack
    }

    return 0 if !defined $arg_ref;

    log_fatal(
        'Second argument for shifting methods can be only options hash reference. In ' . $stack
    ) if ref $arg_ref ne 'HASH';
    my $unknown = first { $_ ne 'without_children' && $_ ne 'skip_if_descendant' } keys %{$arg_ref};
    log_warn("Unknown switch '$unknown' for $stack") if defined $unknown;
    return 0;
}

sub shift_after_node {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return if $self == $reference_node;
    return if _check_shifting_method_args(@_);
    return $self->_shift_to_node( $reference_node, 1, $arg_ref->{without_children} ) if $arg_ref;
    return $self->_shift_to_node( $reference_node, 1, 0 );
}

sub shift_before_node {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return if $self == $reference_node;
    return if _check_shifting_method_args(@_);
    return $self->_shift_to_node( $reference_node, 0, $arg_ref->{without_children} ) if $arg_ref;
    return $self->_shift_to_node( $reference_node, 0, 0 );
}

sub shift_after_subtree {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return if _check_shifting_method_args(@_);

    my $last_node;
    if ( $arg_ref->{without_children} ) {
        ($last_node) = reverse grep { $_ != $self } $reference_node->descendants( { add_self => 1 } );
    }
    else {
        $last_node = $reference_node->descendants( { except => $self, last_only => 1, add_self => 1 } );
    }
    return if !defined $last_node;
    return $self->_shift_to_node( $last_node, 1, $arg_ref->{without_children} ) if $arg_ref;
    return $self->_shift_to_node( $last_node, 1, 0 );
}

sub shift_before_subtree {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return if _check_shifting_method_args(@_);

    my $first_node;
    if ( $arg_ref->{without_children} ) {
        ($first_node) = grep { $_ != $self } $reference_node->descendants( {  add_self => 1 } );
    }
    else {
        $first_node = $reference_node->descendants( { except => $self, first_only => 1, add_self => 1 } );
    }
    return if !defined $first_node;
    return $self->_shift_to_node( $first_node, 0, $arg_ref->{without_children} ) if $arg_ref;
    return $self->_shift_to_node( $first_node, 0, 0 );
}

# This method does the real work for all shift_* methods.
# However, due to unfriendly name and arguments it's not public.
sub _shift_to_node {
    my ( $self, $reference_node, $after, $without_children ) = @_;
    my $root = $self->[$ROOT];
    my @all_nodes = @{$root->[$DESCENDANTS]};

    # Make sure that ord of all nodes is defined
    #my $maximal_ord = @all_nodes; -this does not work, since there may be gaps in ordering
    my $maximal_ord = 10000;
    foreach my $d (@all_nodes) {
        if ( !defined $d->ord ) {
            $d->[$ORD] = $maximal_ord++;
        }
    }

    # Which nodes are to be moved?
    # $self only (the {without_children=>1} switch)
    # or $self and all its descendants (the default)?
    my @nodes_to_move;
    if ($without_children) {
        @nodes_to_move = ($self);
    }
    else {
        @nodes_to_move = $self->descendants( { add_self => 1 } );
    }

    # Let's make a hash, so we can easily recognize which nodes are to be moved.
    my %is_moving = map { $_ => 1 } @nodes_to_move;

    # Recompute ord of all nodes.
    # The technical root has ord=0 and the first node will have ord=1.
    my $counter     = 1;
    my $nodes_moved = 0;
    @all_nodes = sort { $a->[$ORD] <=> $b->[$ORD] } @all_nodes;
    foreach my $node (@all_nodes) {

        # We skip nodes that are being moved.
        # Their ord is recomuted elsewhere (look 8 lines down).
        next if $is_moving{$node};

        # If moving "after" a reference node
        # then ord of the $node can be recomputed now
        # even if it is actually the $reference_node.
        if ($after) {
            $node->[$ORD] = $counter++;
        }

        # Now we insert (i.e. recompute ord of) all nodes which are being moved.
        # The nodes are inserted in the original order.
        if ( $node == $reference_node ) {
            foreach my $moving_node (@nodes_to_move) {
                $moving_node->[$ORD] = $counter++;
            }
            $nodes_moved = 1;
        }

        # If moving "before" a node, then now it is the right moment
        # for recomputing ord of the $node
        if ( !$after ) {
            $node->[$ORD] = $counter++;
        }
    }

    # If $is_moving{$reference_node}, e.g. when there is just one node in the tree,
    # we need to do the reordering now (otherwise the ord would be still 10000).
    if ( !$nodes_moved ) {
        foreach my $moving_node (@nodes_to_move) {
            $moving_node->[$ORD] = $counter++;
        }
    }
    @all_nodes = sort { $a->[$ORD] <=> $b->[$ORD] } @all_nodes;
    $root->[$DESCENDANTS] = \@all_nodes;
    return;
}

1;
