package UD::Block::Read::CoNLLU;
use UD::Core::Common;
extends 'UD::Core::Block';
#extends 'UD::Core::DocumentReader';

my ($DESCENDANTS, $BUNDLE, $FIRSTCHILD, $NEXTSIBLING, $PARENT, $ROOT, $ORD,) = (0..10);

sub process_document {
    my ($self, $doc) = @_;

    # TODO $self->from
    #open my $fh, '<:utf8', $conllu_file;
    my $conllu_file = '/dev/stdin';
    binmode STDIN, 'utf8';
    my $fh = \*STDIN;

    my $bundle = $doc->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
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
            my $bundle = $doc->create_bundle();
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
                                  $form, $lemma, $upos, $xpos, $feats, $deprel, $deps, $misc], 'UD::Core::Node';
            push @nodes, $new_node;
            push @parents, $head;
            # TODO deps
            # TODO convert feats into iset
        }

    }

    #close $fh;

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

1;