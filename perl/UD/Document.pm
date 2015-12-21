package UD::Document;
use autodie;
use Scalar::Util qw(weaken);
use UD::Node;

# TODO bundles instead of trees

#use Moo;
#has trees => (is=>'ro', builder => sub {[]});

sub new {
    my ($class) = @_;
    my $self = {trees=>[]};
    return bless $self, $class;
}

sub load_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $root = $self->create_tree();
    my @nodes = ($root);
    my @parents = (0);
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            $root = $self->create_tree();
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /\d+/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = $root->create_child(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, misc=>$misc);
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
        pop @{$self->{trees}};
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
    foreach my $tree (@{$self->{trees}}){
        foreach my $node ($tree->descendants){
            print {$fh} join("\t", map {defined $_ and $_ ne '' ? $_ : '_'}
                $node->ord, $node->form, $node->lemma, $node->upos, $node->xpos,
                $node->feats, $node->parent->ord, $node->deprel, $node->misc,
            ), "\n";
        }
        print {$fh} "\n";
    }
    close $fh;

}

sub create_tree {
    my ($self, $args) = @_;
    # TODO args->{before} args->{after}
    my $root = UD::Node->new();
    weaken( $root->{_root} = $root );
    push @{$self->{trees}}, $root;
    return $root;
}

1;
