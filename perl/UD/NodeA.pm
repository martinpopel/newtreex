package UD::NodeA;
use strict;
use warnings;
use Carp qw(confess cluck);

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

sub _create_root {
    my ($class, $bundle) = @_;
    my $root = bless [], $class;
    $root->[$DESCENDANTS] = [];
    $root->[$ORD] = 0;
    $root->[$BUNDLE] = $bundle;
    $root->[$ROOT] = $root;
    return $root;
}

sub set_parent {
    my ($self, $parent, $args) = @_;
    confess('set_parent(undef) not allowed') if !defined $parent;

    if ( ($self == $parent || UD::NodeA::is_descendant_of($parent, $self) )) {
        return if $args && $args->{cycles} eq 'skip';
        my $b_id = $self->bundle->id;
        my $n_id = $self->ord; # TODO id instead of ord?
        my $p_id = $parent->ord;
        confess "Bundle $b_id: Attempt to set parent of $n_id to the node $p_id, which would lead to a cycle.";
    }

    #$self->cut() if $self->[$PARENT];
    my $origparent = $self->[$PARENT];
    if ($origparent){
        my $node = $origparent->[$FIRSTCHILD];
        if ($self == $node) {
            $origparent->[$FIRSTCHILD] = $self->[$NEXTSIBLING];
        } else {
            while ($node && $self != $node->[$NEXTSIBLING]){
                $node = $node->[$NEXTSIBLING];
            }
            $node->[$NEXTSIBLING] = $self->[$NEXTSIBLING] if $node;
        }
    }


    $self->[$PARENT] = $parent;
    if (!$self->[$ROOT]){
        my $root = $parent->[$ROOT];
        $self->[$ROOT] = $root;
        # push returns the new number of elements in the array,
        # We need $root->[$DESCENDANTS][$n][$ORD] == $n+1, for any $n.
        $self->[$ORD] = push @{$root->[$DESCENDANTS]}, $self;
    }

    $self->[$NEXTSIBLING] = $parent->[$FIRSTCHILD];
    $parent->[$FIRSTCHILD] = $self;
    return;
}

sub remove {
    my ($self, $arg_ref) = @_;
    my $root = $self->[$ROOT];
    if ( $root == $self ) {
        confess 'Tree root cannot be removed using $root->remove().'
              . ' Use $bundle->remove_tree($selector) instead';
    }

    my @children = UD::NodeA::children($self);
    my $parent = $self->[$PARENT];
    if (@children){
        my $what_to_do = 'remove';
        if ($arg_ref && $arg_ref->{children}){
            $what_to_do = $arg_ref->{children};
        }
        if ($what_to_do =~ /^rehang/){
            foreach my $child (@children){
                UD::NodeA::set_parent($child, $parent);
            }
        }
        if ($what_to_do =~ /warn$/){
            warn $self->address . " is being removed by remove({children=>$what_to_do}), but it has (unexpected) children";
        }
    }

    my @to_remove = sort {$a->[$ORD] <=> $b->[$ORD]} ($self, UD::NodeA::_descendantsF($self));
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
    #$self->cut();
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

    # By reblessing we make sure that
    # all methods called on removed nodes will result in fatal errors.
    foreach $node (@to_remove){
        undef @$node;
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
    UD::NodeA::set_parent($child, $self);
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

    if ($args){
        push @descs, $self if $args->{add_self};
        if ($args->{first_only}){
            my $first = pop @descs;
            foreach my $node (@descs) {
                $first = $node if $node->[$ORD] < $first->[$ORD];
            }
            return $first;
        }
        if ($args->{last_only}){
            my $last = pop @descs;
            foreach my $node (@descs) {
                $last = $node if $node->[$ORD] > $last->[$ORD];
            }
            return $last;
        }
    }

    return sort {$a->[$ORD] <=> $b->[$ORD]} @descs;
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

sub bundle { $_[0]->[$ROOT][$BUNDLE]; }

sub document { $_[0]->[$ROOT][$BUNDLE]->document; }

sub address { $_[0]->bundle->id . '-' . $_[0]->[$ORD]; } #???

sub is_root { !$_[0]->[$PARENT]; }

sub log_fatal { confess @_; }
sub log_warn { cluck @_; }

sub prev_node {
    my ($self) = @_;
    my $ord = $self->[$ORD] - 1;
    return undef if $ord <= 0;
    return $self->[$ROOT][$DESCENDANTS][$ord];
}

sub next_node {
    my ($self) = @_;
    return $self->[$ROOT][$DESCENDANTS][$self->[$ORD] + 1];
}

sub shift_before_node {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return UD::NodeA::_shift_to_node($self, $reference_node, 0, 0, $arg_ref);
}

sub shift_after_node {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return UD::NodeA::_shift_to_node($self, $reference_node, 1, 0, $arg_ref);
}

sub shift_before_subtree {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return UD::NodeA::_shift_to_node($self, $reference_node, 0, 1, $arg_ref);
}

sub shift_after_subtree {
    my ( $self, $reference_node, $arg_ref ) = @_;
    return UD::NodeA::_shift_to_node($self, $reference_node, 1, 1, $arg_ref);
}

# This method does the real work for all shift_* methods.
# However, due to unfriendly name and arguments it's not public.
sub _shift_to_node {
    my ( $self, $reference_node, $after, $subtree, $args) = @_;

    # $node->shift_after_node($node) should result in no action.
    return if !$subtree && $self == $reference_node;

    # Extract the optional arguments from $args.
    my ($without_children, $skip_if_descendant);
    if ($args){
        $without_children = $args->{without_children};
        $skip_if_descendant = $args->{skip_if_descendant};
    }

    # If $reference_node is a descendant of $self and without_children=>1 was not used
    # we should raise an exception. However, checking this takes a little time,
    # so we defer this check, until we have %is_moving.
    # Only if the user asked skip_if_descendant=>1, i.e. if this situation is expected
    # and should not raise the exception, we do the check now.
    return if $skip_if_descendant && !$without_children && UD::NodeA::is_descendant_of($reference_node, $self);

    # For shift_subtree_* methods, we need to find the real reference node first.
    if ($subtree) {
        if ($without_children) {
            my $new_ref;
            if ($after) {
                foreach my $node ($reference_node, UD::NodeA::_descendantsF($reference_node)){
                    next if $node == $self;
                    $new_ref = $node if !$new_ref || ($node->[$ORD] > $new_ref->[$ORD]);
                }
            } else {
                foreach my $node ($reference_node, UD::NodeA::_descendantsF($reference_node)){
                    next if $node == $self;
                    $new_ref = $node if !$new_ref || ($node->[$ORD] < $new_ref->[$ORD]);
                }
            }
            return if !$new_ref;
            $reference_node = $new_ref;
        } else {
            $reference_node = UD::NodeA::descendants($reference_node, {
                except => $self, add_self => 1, ($after ? (last_only => 1) : (first_only => 1)),
            } );
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
        @nodes_to_move = UD::NodeA::descendants($self, { add_self => 1 } );
    }

    # Let's make a hash, so we can easily recognize which nodes are to be moved.
    my %is_moving = map { $_ => 1 } @nodes_to_move;
    if (!$skip_if_descendant && $is_moving{$reference_node}){
            log_fatal '$reference_node is a descendant of $self.'
                    . ' Maybe you have forgotten {without_children=>1}. ' . "\n";
    }

    # Recompute ord of all nodes.
    # The technical root has ord=0 and the first node will have ord=1.
    my $root = $self->[$ROOT];
    my $all_nodes = $root->[$DESCENDANTS];
    my $reference_ord = $reference_node->[$ORD];
    my $first_ord = $nodes_to_move[0][$ORD];
    my $last_ord = $nodes_to_move[-1][$ORD];
    $first_ord = $reference_ord if $reference_ord < $first_ord;
    $last_ord  = $reference_ord if $reference_ord > $last_ord;
    my $counter = $first_ord;
    my $node;
    foreach my $ord ($first_ord .. $last_ord) {
        $node = $all_nodes->[$ord-1];

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
        }

        # If moving "before" a node, then now it is the right moment
        # for recomputing ord of the $node
        if ( !$after ) {
            $node->[$ORD] = $counter++;
        }
    }

    my @all_nodes = sort { $a->[$ORD] <=> $b->[$ORD] } @$all_nodes;
    $root->[$DESCENDANTS] = \@all_nodes;
    return;
}

sub destroy {
    my ($self) = @_;
    foreach my $node (@{$self->[$DESCENDANTS]}){
        undef @$node;
    }
    undef @{$self->[$DESCENDANTS]};
    undef @$self;
    return;
}

1;
