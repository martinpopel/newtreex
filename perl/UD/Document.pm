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
    my $bundle = UD::Bundle->new({id=>1 + @{$self->{_bundles}}});
    weaken( $bundle->{_doc} = $self );
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
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    my $comment = '';
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            if (length $comment){
                $nodes[0]->{comment} = $comment;
                $comment = '';
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ s/^#// ){
            $comment = $comment . $line . "\n";
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = $class->new( _root=>$root, # TODO: don't set _root here?
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            # TODO weaken($new_node->{_root}) # = $root
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
    foreach my $bundle ($self->bundles){
        foreach my $tree ($bundle->trees){
            my $comment = $tree->{comment};
            if (length $comment){
                chomp $comment;
                $comment =~ s/\n/\n#/g;
                print {$fh} "#", $comment, "\n";
            }
            foreach my $node ($tree->descendants){
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

1;
