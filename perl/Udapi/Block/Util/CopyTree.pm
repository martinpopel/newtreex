package Udapi::Block::Util::CopyTree;
use Udapi::Core::Common;
extends 'Udapi::Core::Block';

has_ro to_zone => (required=>1);

sub process_tree {
    my ( $self, $root ) = @_;
    my $bundle = $root->bundle;
    my $new_root = $bundle->create_tree($self->to_zone);
    $self->copy_tree($root, $new_root);
    return;
}

sub copy_tree {
    my ($self, $from, $to) = @_;
    foreach my $from_child ($from->children){
        my $to_child = $from_child->clone();
        # we could use
        $to_child->set_parent($to);
        $self->copy_tree($from_child, $to_child);
    }
    return;
}

1;

__END__

=pod

=encoding utf-8

=head1 NAME

Udapi::Block::Util::CopyTree - copy tree to another zone

=head1 SYNOPSIS

  # on the command line
  Util::CopyTree zones=en to_zone=en_backup

=head1 AUTHOR

Martin Popel <popel@ufal.mff.cuni.cz>

=head1 COPYRIGHT AND LICENSE

Copyright © 2016 by Institute of Formal and Applied Linguistics, Charles University in Prague

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
