package UD::Document;
use strict;
use warnings;
use autodie;
use Scalar::Util qw(weaken);
use UD::Bundle;

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

sub load_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my $class = 'UD::Node' . $self->{implementation};
    my $store_all_descendants = $class =~ /^UD::NodeClA/;
    my $array_based = ($class eq 'UD::NodeA') || ($class eq 'UD::NodeB');
    my $store_root_in_hash = $class ne 'UD::NodeClAl' && !$array_based;
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc );
    my $comment = '';
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            if ($store_all_descendants){
                $root->{_descendants} = [@nodes[1..$#nodes]];
            } elsif ($array_based){
                $root->[0] = [@nodes[1..$#nodes]];
            }
            if (length $comment){
                $nodes[0]->set_misc($comment);
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
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node;
            if ($array_based){
                $new_node = bless [undef, undef, undef, undef, undef, $root, scalar(@nodes),
                                   $form, $lemma, $upos, $xpos, $feats, $deprel, $deps, $misc], $class;
weaken($new_node->[5]);
            } else {
                $new_node = $class->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            }
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
