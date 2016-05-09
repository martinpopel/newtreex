package Udapi::Core::Document;
use strict;
use warnings;
use autodie;
use Udapi::Core::Bundle;
use Udapi::Core::Node::Root;
use Carp;

sub new {
    my ($class) = @_;
    my $self = {_bundles=>[], };
    return bless $self, $class;
}

sub bundles {@{$_[0]->{_bundles}};}

sub create_bundle {
    my ($self, $args) = @_;
    # TODO args->{before} args->{after}
    my $bundle = Udapi::Core::Bundle->new();
    $bundle->set_id(1 + @{$self->{_bundles}});
    $bundle->_set_document($self);
    push @{$self->{_bundles}}, $bundle;
    return $bundle;
}

my ($ORD, $ROOT, $PARENT, $FIRSTCHILD, $NEXTSIBLING, $MISC) = (0..5);
my $DESCENDANTS = 6;

sub _read_conllu_tree_from_fh {
    my ($self, $fh, $error_context) = @_;

    # We could use _create_root($bundle),
    # but the $bundle is not known yet, it will be specified later.
    my $root = Udapi::Core::Node::Root->new();
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc );
    my $comment = '';

    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        last LINE if $line eq '';
        if ($line =~ s/^#// ){
            $comment = $comment . $line . "\n";
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc ) = split /\t/, $line;
            if (index($id, '-', 1) >=0){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = bless [scalar(@nodes), $root, undef, undef, undef, $misc,
                                  $form, $lemma, $upos, $xpos, $feats, $deprel, $deps], 'Udapi::Core::Node';

            push @nodes, $new_node;
            push @parents, $head;
            # TODO deps
            # TODO convert feats into iset
        }
    }

    # If no nodes were read from $fh (so only $root remained in @nodes),
    # we return undef as a sign of failure (end of file or more than one empty line).
    return undef if @nodes==1;

    # Set dependency parents (now, all nodes of the tree are created).
    # The following code does the same as
    # $nodes[$i]->set_parent($nodes[$parents[$i]]) for my $i (1..$#nodes);
    # but slightly faster (set_parent has some checks we can skip here).
    foreach my $i (1..$#nodes){
        my $parent = $nodes[ $parents[$i] ];
        my $node = $nodes[$i];
        if ($node == $parent){
            confess "Conllu file $error_context (before line $.) contains a cycle: node $id is attached to itself";
        }
        if ($node->[$FIRSTCHILD]) {
            my $grandpa = $parent->[$PARENT];
            while ($grandpa) {
                if ($grandpa == $node){
                    my $b_id = $node->bundle->id;
                    my $p_id = $parent->ord;
                    confess "Conllu file $error_context (before line $.) contains a cycle: nodes $id and $p_id.";
                }
                $grandpa = $grandpa->[$PARENT];
            }
        }
        $node->[$PARENT] = $parent;
        $node->[$NEXTSIBLING] = $parent->[$FIRSTCHILD];
        $parent->[$FIRSTCHILD] = $node;
    }

    # Set root attributes (descendants for faster iteration of all nodes in a tree).
    $root->[$DESCENDANTS] = [@nodes[1..$#nodes]];
    if (length $comment){
        $root->set_misc($comment);
        $comment = '';
    }

    return $root;
}

sub load_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;

    while (my $root = $self->_read_conllu_tree_from_fh($fh, $conllu_file)){
        my $bundle = $self->create_bundle();
        $bundle->add_tree($root);
    }

    close $fh;
    return;
}

sub save_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '>:utf8', $conllu_file;
    my @nodes;
    foreach my $bundle ($self->bundles){
        foreach my $tree ($bundle->trees){
            @nodes = $tree->descendants;
            # Empty sentences are not allowed in CoNLL-U.
            next if !@nodes;
            my $comment = $tree->misc;
            if (length $comment){
                chomp $comment;
                $comment =~ s/\n/\n#/g;
                print {$fh} "#", $comment, "\n";
            }
            foreach my $node (@nodes){
                print {$fh} join("\t", map {(defined $_ and $_ ne '') ? $_ : '_'}
                    $node->ord, $node->form, $node->lemma, $node->upos, $node->xpos,
                    $node->feats, $node->parent->ord, $node->deprel, $node->deps, $node->misc,
                ), "\n";
            }
            print {$fh} "\n";
        }
    }
    close $fh;
    return;
}

sub destroy {
    my ($self) = @_;
    my $bundles_ref = $self->{_bundles};
    foreach my $bundle (@$bundles_ref){
        $bundle->destroy();
    }
    undef @$bundles_ref;
    undef %$self;
    return;
}

1;
