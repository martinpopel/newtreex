package UD::Document;
use strict;
use warnings;
use autodie;
use UD::Bundle;
use Carp;

sub new {
    my ($class, $implementation) = @_;
    my $self = {_bundles=>[], implementation => $implementation || ''};
    return bless $self, $class;
}

sub bundles {@{$_[0]->{_bundles}};}

sub create_bundle {
    my ($self, $args) = @_;
    # TODO args->{before} args->{after}
    my $bundle = UD::Bundle->new();
    $bundle->set_id(1 + @{$self->{_bundles}});
    $bundle->set_document($self);
    push @{$self->{_bundles}}, $bundle;
    return $bundle;
}

my ($DESCENDANTS, $BUNDLE, $FIRSTCHILD, $NEXTSIBLING, $PARENT, $ROOT, $ORD,) = (0..10);

sub load_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my $class = 'UD::Node' . $self->{implementation};
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc );
    my $comment = '';
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                # faster version of $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
                my $parent = $nodes[ $parents[$i] ];
                my $node = $nodes[$i];
                if ($node == $parent){
                    my $b_id = $self->bundle->id;
                    confess "Conllu file $conllu_file contains cycles: Bundle $b_id: node $id is attached to itself";
                }
                if ($node->[$FIRSTCHILD]) {
                    my $grandpa = $parent->[$PARENT];
                    while ($grandpa) {
                        if ($grandpa == $node){
                            my $b_id = $node->bundle->id;
                            my $p_id = $parent->ord;
                            confess "Conllu file $conllu_file contains cycles: Bundle $b_id: nodes $id and $p_id.";
                        }
                        $grandpa = $grandpa->[$PARENT];
                    }
                }
                $node->[$PARENT] = $parent;
                $node->[$NEXTSIBLING] = $parent->[$FIRSTCHILD];
                $parent->[$FIRSTCHILD] = $node;
            }
            $root->[$DESCENDANTS] = [@nodes[1..$#nodes]];
            if (length $comment){
                $root->set_misc($comment);
                $comment = '';
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ s/^#// ){
            $comment = $comment . $line . "\n";
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc ) = split /\t/, $line;
            if (index($id, '-', 1) >=0){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = bless [undef, undef, undef, undef, undef, $root, scalar(@nodes),
                                  $form, $lemma, $upos, $xpos, $feats, $deprel, $deps, $misc], $class;
            push @nodes, $new_node;
            push @parents, $head;
            # TODO deps
            # TODO convert feats into iset
        }
        
    }
    close $fh;
    # The last bundle should be empty (if the file ended with an empty line),
    # so we need to remove it. But let's check it.
    if (@nodes == 1){
        pop @{$self->{_bundles}};
    } else {
        foreach my $i (1..$#nodes) {
            $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
        }
    }
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
