package UD::Document;
use strict;
use warnings;
use autodie;
use Scalar::Util qw(weaken);
use UD::Bundle;
use UD::Node;

#use Moo;
#has _bundles => (is=>'ro', builder => sub {[]});

sub new {
    my ($class) = @_;
    my $self = {_bundles=>[]};
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

sub _chomp {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    while (my $line = <$fh>) {
        chomp $line;
    }
    close $fh;
    return;
}

sub _comments {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
        } elsif ($line =~ /^#/ ){
        } else {
            #my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        }
        
    }
    close $fh;
    return;
}

sub _splitF {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
        } elsif ($line =~ /^#/ ){
        } else {
            () = split /\t/, $line;
        }
    }
    close $fh;
    return;
}

sub _split {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
        } elsif ($line =~ /^#/ ){
        } else {
            my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        }
    }
    close $fh;
    return;
}

sub _split_reuse {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
        } elsif ($line =~ /^#/ ){
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        }
    }
    close $fh;
    return;
}

sub _split_pole {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    my @p;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
        } elsif ($line =~ /^#/ ){
        } else {
            @p = split /\t/, $line;
        }
    }
    close $fh;
    return;
}


sub _nodes_throwaway {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq '' or $line =~ /^#/;
        my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
    }
    close $fh;
    return;
}

sub _nodes_throwaway_reuse {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest);
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq '' or $line =~ /^#/;
        ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
    }
    close $fh;
    return;
}

sub _nodes_throwaway_pole {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    my @p;
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq '' or $line =~ /^#/;
        @p = split /\t/, $line;
        my $new_node = UD::Node->new(ord=>$p[0], form=>$p[1], lemma=>$p[2], upos=>$p[3], xpos=>$p[4], feats=>$p[5], deprel=>$p[7], deps=>$p[8], misc=>$p[9]);
    }
    close $fh;
    return;
}

my @nodes;
sub _nodes_array {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest);
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq '' or $line =~ /^#/;
        ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
        my $new_node = UD::Node->new(ord=>$id, form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
        push @nodes, $new_node;
    }
    close $fh;
    return;
}

sub _nodes_bundles {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            #foreach my $i (1..$#nodes){
                #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            #}
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            #if ($id !~ /^\d+$/){
            #    # TODO multiword tokens
            #    next LINE;
            #}
            my $node = UD::Node->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            weaken ($node->{_parent} = $root);
            weaken ($node->{_root} = $root);
            push @{$root->{_children}}, $node;
            #push @nodes, $new_node;
            #push @parents, $head;
        }
        
    }
    close $fh;
    return;
}

sub _nonodes {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node;
            # my $new_node = $root->create_child(
            #     ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            push @nodes, $new_node;
            push @parents, $head;
        }
        
    }
    close $fh;
    return;
}




sub _norehang {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = $root->create_child(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            push @nodes, $new_node;
            push @parents, $head;
        }
        
    }
    close $fh;
    return;
}

sub _nodesonly {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            #my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            #warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            #if ($id !~ /^\d+$/){
            #    # TODO multiword tokens
            #    next LINE;
            #}
            my $new_node = $root->create_child(
                 ord=>scalar(@nodes), form=>'', lemma=>'', upos=>'', xpos=>'', feats=>'', deprel=>'', deps=>'', misc=>'');
            #    ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
            push @nodes, $new_node;
            #push @parents, $head;
        }
        
    }
    close $fh;
    return;
}


sub load_conlluFnosetparent {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
                my ($node, $parent) = ($nodes[$i], $nodes[ $parents[$i] ]);
                weaken ($node->{_parent} = $parent);
                weaken ($node->{_root} = $root);
                $parent->{_children} ||= [];
                push @{$parent->{_children}}, $node;
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = UD::Node->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
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
            #$nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            my ($node, $parent) = ($nodes[$i], $nodes[ $parents[$i] ]);                
            weaken ($node->{_parent} = $parent);
            weaken ($node->{_root} = $root);
            $parent->{_children} ||= [];
            push @{$parent->{_children}}, $node;
        }
    }
    return;
}

sub load_conlluF {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent( $nodes[ $parents[$i] ] );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = UD::Node->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
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


sub load_conllu_nocheck {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent( $nodes[ $parents[$i] ], {cycles=>'no-check'} );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = UD::Node->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
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
            $nodes[$i]->set_parent( $nodes[ $parents[$i] ], {cycles=>'no-check'} );
        }
    }
    return;
}

sub load_conllu_nocheck2 {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
    my @nodes = ($root);
    my @parents = (0);
    my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest );
    LINE:
    while (my $line = <$fh>) {
        chomp $line;
        if ($line eq ''){
            next LINE if @nodes==1;
            foreach my $i (1..$#nodes){
                $nodes[$i]->set_parent_nocheck( $nodes[ $parents[$i] ] );
            }
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = UD::Node->new(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
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
            $nodes[$i]->set_parent_nocheck( $nodes[ $parents[$i] ] );
        }
    }
    return;
}


sub load_conllu {
    my ($self, $conllu_file) = @_;
    open my $fh, '<:utf8', $conllu_file;
    
    my $bundle = $self->create_bundle();
    my $root = $bundle->create_tree(); # {selector=>''}
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
            my $bundle = $self->create_bundle();
            $root = $bundle->create_tree(); # {selector=>''}
            @nodes = ($root);
            @parents = (0);
        } elsif ($line =~ /^#/ ){
            # TODO comments
        } else {
            my ( $id, $form, $lemma, $upos, $xpos, $feats, $head, $deprel, $deps, $misc, $rest ) = split /\t/, $line;
            warn "Extra columns in CONLL-U file '$conllu_file':\n$rest\n" if $rest;
            if ($id !~ /^\d+$/){
                # TODO multiword tokens
                next LINE;
            }
            my $new_node = $root->create_child(
                ord=>scalar(@nodes), form=>$form, lemma=>$lemma, upos=>$upos, xpos=>$xpos, feats=>$feats, deprel=>$deprel, deps=>$deps, misc=>$misc);
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
            foreach my $node ($tree->descendants){
                print {$fh} join("\t", map {(defined $_ and $_ ne '') ? $_ : '_'}
                    $node->ord, $node->form, $node->lemma, $node->upos, $node->xpos,
                    $node->feats, $node->parent->ord, $node->deprel, $node->deps, $node->misc,
                ), "\n";
            }
        }
        print {$fh} "\n";
    }
    close $fh;
    return;
}

1;
