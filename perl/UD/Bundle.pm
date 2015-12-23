package UD::Bundle;
use autodie;
use Carp;
use Scalar::Util qw(weaken);
use UD::Node;

#use Moo;
#has trees => (is=>'ro', builder => sub {[]});

sub new {
    my ($class, $attrs) = @_;
    $attrs ||= {};
    $attrs{_trees} = {};
    return bless $attrs, $class;
}

sub id {$_[0]->{id};}
sub document {$_[0]->{_doc};}

sub trees {
    my ($self) = @_;
    return values %{$self->{_trees}};
}

sub create_tree {
    my ($self, $args) = @_;
    $args ||= {};
    my $selector = $args->{selector} //= '';
    confess "Tree with selector '$selector' already exists" if $self->{_trees}{$selector};
    # TODO $args->{language} ||= 'unk' or even delete $args->{language}
    # TODO reuse the hash $args
    my $root = UD::Node->new(%$args);
    weaken( $root->{_root} = $root );
    weaken( $root->{_bundle} = $self );
    $root->{ord} = 0;
    $self->{_trees}{$selector} = $root;
    return $root;
}

1;
