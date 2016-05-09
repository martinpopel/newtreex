package Udapi::Core::Node::Root;
use strict;
use warnings;
use Carp qw(confess cluck);

my @ATTRS;
my (
    $ORD, $ROOT, $PARENT, $FIRSTCHILD, $NEXTSIBLING, $MISC, # both root and node
    $DESCENDANTS, $BUNDLE, $ZONE, $SENTENCE,                # root only
);

BEGIN {
    @ATTRS = qw(ord root parent firstchild nextsibling misc
                descendants bundle zone sentence);
    ($ORD, $ROOT, $PARENT, $FIRSTCHILD, $NEXTSIBLING, $MISC) = (0..5);
    ($DESCENDANTS, $BUNDLE, $ZONE, $SENTENCE)                = (6..9);
}

use Class::XSAccessor::Array {
    setters => { _set_zone=>$ZONE, _set_bundle=>$BUNDLE, set_misc=>$MISC, set_sentence=>$SENTENCE },
    getters => { zone=>$ZONE, bundle=>$BUNDLE, misc=>$MISC, sentence=>$SENTENCE },
};

sub new {
    my ($class, $bundle) = @_;
    my $root = bless [], $class;
    $root->[$DESCENDANTS] = [];
    $root->[$ORD] = 0;
    $root->[$BUNDLE] = $bundle;
    $root->[$ROOT] = $root;
    return $root;
}

sub set_zone {
    my ($self, $zone) = @_;
    confess "'$zone' is not a valid zone name" if $zone !~ /^[a-z-]+(_[A-Za-z0-9-])?$/;
    confess "'all' cannot be used as a zone name" if $zone eq 'all';
    my $bundle = $self->[$BUNDLE];
    confess "Tree with zone '$zone' already exists in bundle " . $bundle->id
        if $bundle && any {$zone eq $_->zone} $bundle->trees;
    $self->[$ZONE] = $zone;
    return;
}

# The following methods are well defined for root
# (eventhough the well-defined value for parent() is 'undef').
sub parent {return undef;}
sub root {return $_[0];}
sub ord {return 0;}

sub descendants {
    #my ($self, $args) = @_;
    return @{$_[0][$DESCENDANTS]} if !$_[1]; # !$args (most common case)
    if ($_[1]{except}){
        @_ = ($_[0], $_[1]{add_self}, $_[1]{first_only}, $_[1]{last_only}, $_[1]{except});
        goto &Udapi::Core::Node::_descendants;
    }
    if ($_[1]{first_only}){
        return $_[0] if $_[1]{add_self};
        return $_[0]->[$DESCENDANTS][0];
    }
    return $_[0]->[$DESCENDANTS][-1] if $_[1]{last_only};
    return ($_[0], @{$_[0]->[$DESCENDANTS]}) if $_[1]{add_self};
    confess 'unknown option for descendants(): '. %{$_[1]};
}

*_descendantsF = \&descendants;
*children = \&Udapi::Core::Node::children;

sub next_node { return $_[0]->[$DESCENDANTS][1]; }
sub prev_node { return undef; }
sub precedes { return 1;}
sub is_descendant_of { return 0; }

# The root is a technical node which has no CoNLL-U attributes.
# However, imagine a feature extraction code:
# foreach $node ($root->descendants) {
#    say $node->form . "-" . $node->parent->form;
# }
# It is useful if even the root returns some special value.
# Otherwise, we would have to write:
#   say $node->form . "-" . ($node->parent->is_root ? '<ROOT>' : $node->parent->form);
#

sub form {return '<ROOT>';}
sub lemma {return '<ROOT>';}
sub upos {return '<ROOT>';}
sub xpos {return '<ROOT>';}
sub feats {return '<ROOT>';} # TODO: empty feats object
sub deprel {return '<ROOT>';}
sub deps {return '<ROOT>';}

sub get_attrs {
    my $self = shift;
    return map {
          $_ eq 'ord'    ? 0
        : $_ eq 'misc'   ? $self->[$MISC]
        : /^(form|lemma|[ux]pos|feats|deprel|deps)$/ ? '<ROOT>'
        : confess "Unknown attribute '$_'";
    } @_;
}

sub create_child {
    my $self = shift;
    my $child = Udapi::Core::Node->new(@_);
    Udapi::Core::Node::set_parent($child, $self);
    return $child;
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

sub remove {
    confess 'Tree root cannot be removed using $root->remove().'
          . ' Use $bundle->remove_tree($selector) instead';
}

1;
